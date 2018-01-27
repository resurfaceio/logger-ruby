# coding: utf-8
# © 2016-2018 Resurface Labs LLC

class HttpRules

  def self.basic_rules
    %q(/request_header:cookie|response_header:set-cookie/ remove
/(request|response)_body|request_param/ replace /[a-zA-Z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)/, /x@y.com/
/request_body|request_param|response_body/ replace /[0-9\.\-\/]{9,}/, /xyxy/
)
  end

  def self.parse(rules)
    result = []
    unless rules.nil?
      rules = rules.gsub(/^\s*include basic\s*$/, basic_rules)
      rules.each_line do |rule|
        parsed = parse_rule(rule)
        result << parsed unless parsed.nil?
      end
    end
    result
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
    elsif (m = r.match(REGEX_REMOVE_UNLESS))
      HttpRule.new('remove_unless', parse_regex(r, m[1]), parse_regex(r, m[2]))
    elsif (m = r.match(REGEX_REPLACE))
      HttpRule.new('replace', parse_regex(r, m[1]), parse_regex(r, m[2]), parse_string(r, m[3]))
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
    elsif (m = r.match(REGEX_STOP_UNLESS))
      HttpRule.new('stop_unless', parse_regex(r, m[1]), parse_regex(r, m[2]))
    else
      raise RuntimeError.new("Invalid rule: #{r}")
    end
  end

  protected

  def self.parse_regex(r, regex)
    begin
      return Regexp.compile(parse_string(r, regex))
    rescue RegexpError
      raise RuntimeError.new("Invalid regex (#{regex}) in rule: #{r}")
    end
  end

  def self.parse_string(r, str)
    %w(~ ! % | /).each do |sep|
      if (m = str.match(/^[#{sep}](.*)[#{sep}]$/))
        m1 = m[1]
        raise RuntimeError.new("Unescaped separator (#{sep}) in rule: #{r}") if m1.match(/^[#{sep}].*|.*[^\\][#{sep}].*/)
        return m1.gsub("\\#{sep}", sep)
      end
    end
    raise RuntimeError.new("Invalid expression (#{str}) in rule: #{r}")
  end

  REGEX_ALLOW_HTTP_URL = /^\s*allow_http_url\s*(#.*)?$/.freeze
  REGEX_BLANK_OR_COMMENT = /^\s*([#].*)*$/.freeze
  REGEX_COPY_SESSION_FIELD = /^\s*copy_session_field\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_REMOVE = /^\s*([~!%|\/].+[~!%|\/])\s*remove\s*(#.*)?$/.freeze
  REGEX_REMOVE_IF = /^\s*([~!%|\/].+[~!%|\/])\s*remove_if\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_REMOVE_UNLESS = /^\s*([~!%|\/].+[~!%|\/])\s*remove_unless\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_REPLACE = /^\s*([~!%|\/].+[~!%|\/])\s*replace[\s]+([~!%|\/].+[~!%|\/]),[\s]+([~!%|\/].*[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_SAMPLE = /^\s*sample\s+(\d+)\s*(#.*)?$/.freeze
  REGEX_SKIP_COMPRESSION = /^\s*skip_compression\s*(#.*)?$/.freeze
  REGEX_SKIP_SUBMISSION = /^\s*skip_submission\s*(#.*)?$/.freeze
  REGEX_STOP = /^\s*([~!%|\/].+[~!%|\/])\s*stop\s*(#.*)?$/.freeze
  REGEX_STOP_IF = /^\s*([~!%|\/].+[~!%|\/])\s*stop_if\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze
  REGEX_STOP_UNLESS = /^\s*([~!%|\/].+[~!%|\/])\s*stop_unless\s+([~!%|\/].+[~!%|\/])\s*(#.*)?$/.freeze

end
