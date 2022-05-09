# coding: utf-8
# © 2016-2022 Resurface Labs Inc.

class HttpRules

  DEBUG_RULES = "allow_http_url\ncopy_session_field /.*/\n".freeze

  STANDARD_RULES = %q(/request_header:cookie|response_header:set-cookie/ remove
/(request|response)_body|request_param/ replace /[a-zA-Z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)/, /x@y.com/
/request_body|request_param|response_body/ replace /[0-9\.\-\/]{9,}/, /xyxy/
).freeze

  STRICT_RULES = %q(/request_url/ replace /([^\?;]+).*/, !\\\\1!
/request_body|response_body|request_param:.*|request_header:(?!user-agent).*|response_header:(?!(content-length)|(content-type)).*/ remove
).freeze

  @@default_rules = STRICT_RULES

  def self.default_rules
    @@default_rules
  end

  def self.default_rules=(val)
    @@default_rules = val.gsub(/^\s*include default\s*$/, '')
  end

  def self.debug_rules
    DEBUG_RULES
  end

  def self.standard_rules
    STANDARD_RULES
  end

  def self.strict_rules
    STRICT_RULES
  end

  def self.parse_rule(r)
    if r.nil? || r.match(REGEX_BLANK_OR_COMMENT)
      nil
    elsif r.match(REGEX_ALLOW_HTTP_URL)
      HttpRule.new('allow_http_url')
    elsif (m = r.match(REGEX_COPY_SESSION_FIELD))
      HttpRule.new('copy_session_field', nil, parse_regex(r, m[1]))
    elsif (m = r.match(REGEX_REMOVE))
      HttpRule.new('remove', parse_regex(r, m[1]))
    elsif (m = r.match(REGEX_REMOVE_IF))
      HttpRule.new('remove_if', parse_regex(r, m[1]), parse_regex(r, m[2]))
    elsif (m = r.match(REGEX_REMOVE_IF_FOUND))
      HttpRule.new('remove_if_found', parse_regex(r, m[1]), parse_regex_find(r, m[2]))
    elsif (m = r.match(REGEX_REMOVE_UNLESS))
      HttpRule.new('remove_unless', parse_regex(r, m[1]), parse_regex(r, m[2]))
    elsif (m = r.match(REGEX_REMOVE_UNLESS_FOUND))
      HttpRule.new('remove_unless_found', parse_regex(r, m[1]), parse_regex_find(r, m[2]))
    elsif (m = r.match(REGEX_REPLACE))
      HttpRule.new('replace', parse_regex(r, m[1]), parse_regex_find(r, m[2]), parse_string(r, m[3]))
    elsif (m = r.match(REGEX_SAMPLE))
      m1 = m[1].to_i
      raise RuntimeError.new("Invalid sample percent: #{m1}") if m1 < 1 || m1 > 99
      HttpRule.new('sample', nil, m1)
    elsif r.match(REGEX_SKIP_COMPRESSION)
      HttpRule.new('skip_compression')
    elsif r.match(REGEX_SKIP_SUBMISSION)
      HttpRule.new('skip_submission')
    elsif (m = r.match(REGEX_STOP))
      HttpRule.new('stop', parse_regex(r, m[1]))
    elsif (m = r.match(REGEX_STOP_IF))
      HttpRule.new('stop_if', parse_regex(r, m[1]), parse_regex(r, m[2]))
    elsif (m = r.match(REGEX_STOP_IF_FOUND))
      HttpRule.new('stop_if_found', parse_regex(r, m[1]), parse_regex_find(r, m[2]))
    elsif (m = r.match(REGEX_STOP_UNLESS))
      HttpRule.new('stop_unless', parse_regex(r, m[1]), parse_regex(r, m[2]))
    elsif (m = r.match(REGEX_STOP_UNLESS_FOUND))
      HttpRule.new('stop_unless_found', parse_regex(r, m[1]), parse_regex_find(r, m[2]))
    else
      raise RuntimeError.new("Invalid rule: #{r}")
    end
  end

  def self.parse_regex(r, regex)
    s = parse_string(r, regex)
    raise RuntimeError.new("Invalid regex (#{regex}) in rule: #{r}") if '*' == s || '+' == s || '?' == s
    s = "^#{s}" unless s.start_with?('^')
    s = "#{s}$" unless s.end_with?('$')
    begin
      return Regexp.compile(s)
    rescue RegexpError
      raise RuntimeError.new("Invalid regex (#{regex}) in rule: #{r}")
    end
  end

  def self.parse_regex_find(r, regex)
    begin
      return Regexp.compile(parse_string(r, regex))
    rescue RegexpError
      raise RuntimeError.new("Invalid regex (#{regex}) in rule: #{r}")
    end
  end

  def self.parse_string(r, expr)
    %w(~ ! % | /).each do |sep|
      if (m = expr.match(/^[#{sep}](.*)[#{sep}]$/))
        m1 = m[1]
        raise RuntimeError.new("Unescaped separator (#{sep}) in rule: #{r}") if m1.match(/^[#{sep}].*|.*[^\\][#{sep}].*/)
        return m1.gsub("\\#{sep}", sep)
      end
    end
    raise RuntimeError.new("Invalid expression (#{expr}) in rule: #{r}")
  end

  def initialize(rules)
    rules = HttpRules.default_rules if rules.nil?

    # load rules from external files
    if rules.start_with?('file://')
      rfile = rules[7..]
      begin
        rules = File.read(rfile)
      rescue
        raise RuntimeError.new("Failed to load rules: #{rfile}")
      end
    end

    # force default rules if necessary
    rules = rules.gsub(/^\s*include default\s*$/, HttpRules.default_rules)
    rules = HttpRules.default_rules unless rules.strip.length > 0

    # expand rule inclues
    rules = rules.gsub(/^\s*include debug\s*$/, DEBUG_RULES)
    rules = rules.gsub(/^\s*include standard\s*$/, STANDARD_RULES)
    rules = rules.gsub(/^\s*include strict\s*$/, STRICT_RULES)
    @text = rules

    # parse all rules
    prs = []
    rules.each_line do |rule|
      parsed = HttpRules.parse_rule(rule)
      prs << parsed unless parsed.nil?
    end
    @length = prs.length

    # break out rules by verb
    @allow_http_url = prs.select {|r| 'allow_http_url' == r.verb}.length > 0
    @copy_session_field = prs.select {|r| 'copy_session_field' == r.verb}
    @remove = prs.select {|r| 'remove' == r.verb}
    @remove_if = prs.select {|r| 'remove_if' == r.verb}
    @remove_if_found = prs.select {|r| 'remove_if_found' == r.verb}
    @remove_unless = prs.select {|r| 'remove_unless' == r.verb}
    @remove_unless_found = prs.select {|r| 'remove_unless_found' == r.verb}
    @replace = prs.select {|r| 'replace' == r.verb}
    @sample = prs.select {|r| 'sample' == r.verb}
    @skip_compression = prs.select {|r| 'skip_compression' == r.verb}.length > 0
    @skip_submission = prs.select {|r| 'skip_submission' == r.verb}.length > 0
    @stop = prs.select {|r| 'stop' == r.verb}
    @stop_if = prs.select {|r| 'stop_if' == r.verb}
    @stop_if_found = prs.select {|r| 'stop_if_found' == r.verb}
    @stop_unless = prs.select {|r| 'stop_unless' == r.verb}
    @stop_unless_found = prs.select {|r| 'stop_unless_found' == r.verb}

    # validate rules
    raise RuntimeError.new('Multiple sample rules') if @sample.length > 1
  end

  def allow_http_url
    @allow_http_url
  end

  def copy_session_field
    @copy_session_field
  end

  def length
    @length
  end

  def remove
    @remove
  end

  def remove_if
    @remove_if
  end

  def remove_if_found
    @remove_if_found
  end

  def remove_unless
    @remove_unless
  end

  def remove_unless_found
    @remove_unless_found
  end

  def replace
    @replace
  end

  def sample
    @sample
  end

  def skip_compression
    @skip_compression
  end

  def skip_submission
    @skip_submission
  end

  def stop
    @stop
  end

  def stop_if
    @stop_if
  end

  def stop_if_found
    @stop_if_found
  end

  def stop_unless
    @stop_unless
  end

  def stop_unless_found
    @stop_unless_found
  end

  def text
    @text
  end

  def apply(details)
    # stop rules come first
    @stop.each {|r| details.each {|d| return nil if r.scope.match(d[0])}}
    @stop_if_found.each {|r| details.each {|d| return nil if r.scope.match(d[0]) && r.param1.match(d[1])}}
    @stop_if.each {|r| details.each {|d| return nil if r.scope.match(d[0]) && r.param1.match(d[1])}}
    passed = 0
    @stop_unless_found.each {|r| details.each {|d| passed += 1 if r.scope.match(d[0]) && r.param1.match(d[1])}}
    return nil if passed != @stop_unless_found.length
    passed = 0
    @stop_unless.each {|r| details.each {|d| passed += 1 if r.scope.match(d[0]) && r.param1.match(d[1])}}
    return nil if passed != @stop_unless.length

    # do sampling if configured
    return nil if !@sample[0].nil? && (rand * 100 >= @sample[0].param1)

    # winnow sensitive details based on remove rules if configured
    @remove.each {|r| details.delete_if {|d| r.scope.match(d[0])}}
    @remove_unless_found.each {|r| details.delete_if {|d| r.scope.match(d[0]) && !r.param1.match(d[1])}}
    @remove_if_found.each {|r| details.delete_if {|d| r.scope.match(d[0]) && r.param1.match(d[1])}}
    @remove_unless.each {|r| details.delete_if {|d| r.scope.match(d[0]) && !r.param1.match(d[1])}}
    @remove_if.each {|r| details.delete_if {|d| r.scope.match(d[0]) && r.param1.match(d[1])}}
    return nil if details.empty?

    # mask sensitive details based on replace rules if configured
    @replace.each {|r| details.each {|d| d[1] = d[1].gsub(r.param1, r.param2) if r.scope.match(d[0])}}

    # remove any details with empty values
    details.delete_if {|d| '' == d[1]}
    details.empty? ? nil : details
  end

  REGEX_ALLOW_HTTP_URL = /^\s*allow_http_url\s*(#.*)?$/.freeze
  REGEX_BLANK_OR_COMMENT = /^\s*([#].*)*$/.freeze
  REGEX_COPY_SESSION_FIELD = /^\s*copy_session_field\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_REMOVE = /^\s*([~!%|\/].+[~!%|\/])\s*remove\s*(#.*)?$/.freeze
  REGEX_REMOVE_IF = /^\s*([~!%|\/].+[~!%|\/])\s*remove_if\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_REMOVE_IF_FOUND = /^\s*([~!%|\/].+[~!%|\/])\s*remove_if_found\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_REMOVE_UNLESS = /^\s*([~!%|\/].+[~!%|\/])\s*remove_unless\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_REMOVE_UNLESS_FOUND = /^\s*([~!%|\/].+[~!%|\/])\s*remove_unless_found\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_REPLACE = /^\s*([~!%|\/].+[~!%|\/])\s*replace[\s]+([~!%|\/].+[~!%|\/]),[\s]+([~!%|\/].*[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_SAMPLE = /^\s*sample\s+(\d+)\s*(#.*)?$/.freeze
  REGEX_SKIP_COMPRESSION = /^\s*skip_compression\s*(#.*)?$/.freeze
  REGEX_SKIP_SUBMISSION = /^\s*skip_submission\s*(#.*)?$/.freeze
  REGEX_STOP = /^\s*([~!%|\/].+[~!%|\/])\s*stop\s*(#.*)?$/.freeze
  REGEX_STOP_IF = /^\s*([~!%|\/].+[~!%|\/])\s*stop_if\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_STOP_IF_FOUND = /^\s*([~!%|\/].+[~!%|\/])\s*stop_if_found\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_STOP_UNLESS = /^\s*([~!%|\/].+[~!%|\/])\s*stop_unless\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_STOP_UNLESS_FOUND = /^\s*([~!%|\/].+[~!%|\/])\s*stop_unless_found\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze

end
