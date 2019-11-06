# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

require 'json'
require 'resurfaceio/base_logger'
require 'resurfaceio/http_message'
require 'resurfaceio/http_rule'
require 'resurfaceio/http_rules'

class HttpLogger < BaseLogger

  AGENT = 'http_logger.rb'.freeze

  @@default_rules = HttpRules.strict_rules

  def self.default_rules
    @@default_rules
  end

  def self.default_rules=(val)
    @@default_rules = val.gsub(/^\s*include default\s*$/, '')
  end

  def self.string_content_type?(s)
    !s.nil? && !(s =~ /^(text\/(html|plain|xml))|(application\/(json|soap|xml|x-www-form-urlencoded))/i).nil?
  end

  def initialize(options = {})
    super(AGENT, options)

    # read rules from param or defaults
    if options.respond_to?(:has_key?) && options.has_key?(:rules)
      @rules = options[:rules].gsub(/^\s*include default\s*$/, @@default_rules)
      @rules = @@default_rules unless @rules.strip.length > 0
    else
      @rules = @@default_rules
    end

    # parse and break rules out by verb
    prs = HttpRules.parse(@rules)
    @rules_allow_http_url = prs.select {|r| 'allow_http_url' == r.verb}.length > 0
    @rules_copy_session_field = prs.select {|r| 'copy_session_field' == r.verb}
    @rules_remove = prs.select {|r| 'remove' == r.verb}
    @rules_remove_if = prs.select {|r| 'remove_if' == r.verb}
    @rules_remove_if_found = prs.select {|r| 'remove_if_found' == r.verb}
    @rules_remove_unless = prs.select {|r| 'remove_unless' == r.verb}
    @rules_remove_unless_found = prs.select {|r| 'remove_unless_found' == r.verb}
    @rules_replace = prs.select {|r| 'replace' == r.verb}
    @rules_sample = prs.select {|r| 'sample' == r.verb}
    @rules_stop = prs.select {|r| 'stop' == r.verb}
    @rules_stop_if = prs.select {|r| 'stop_if' == r.verb}
    @rules_stop_if_found = prs.select {|r| 'stop_if_found' == r.verb}
    @rules_stop_unless = prs.select {|r| 'stop_unless' == r.verb}
    @rules_stop_unless_found = prs.select {|r| 'stop_unless_found' == r.verb}
    @skip_compression = prs.select {|r| 'skip_compression' == r.verb}.length > 0
    @skip_submission = prs.select {|r| 'skip_submission' == r.verb}.length > 0

    # finish validating rules
    raise RuntimeError.new('Multiple sample rules') if @rules_sample.length > 1
    unless @url.nil? || @url.start_with?('https') || @rules_allow_http_url
      @enableable = false
      @enabled = false
    end
  end

  def rules
    @rules
  end

  def log(request, response, response_body = nil, request_body = nil)
    !enabled? || submit(format(request, response, response_body, request_body))
  end

  def format(request, response, response_body = nil, request_body = nil, now = nil)
    details = HttpMessage.build(request, response, response_body, request_body)

    # copy data from session if configured
    unless @rules_copy_session_field.empty?
      ssn = request.session
      if !ssn.nil? && ssn.respond_to?(:keys)
        @rules_copy_session_field.each do |r|
          ssn.keys.each {|d| (details << ["session_field:#{d}", ssn[d].to_s]) if r.param1.match(d)}
        end
      end
    end

    # quit early based on stop rules if configured
    @rules_stop.each {|r| details.each {|d| return nil if r.scope.match(d[0])}}
    @rules_stop_if_found.each {|r| details.each {|d| return nil if r.scope.match(d[0]) && r.param1.match(d[1])}}
    @rules_stop_if.each {|r| details.each {|d| return nil if r.scope.match(d[0]) && r.param1.match(d[1])}}
    passed = 0
    @rules_stop_unless_found.each {|r| details.each {|d| passed += 1 if r.scope.match(d[0]) && r.param1.match(d[1])}}
    return nil if passed != @rules_stop_unless_found.length
    passed = 0
    @rules_stop_unless.each {|r| details.each {|d| passed += 1 if r.scope.match(d[0]) && r.param1.match(d[1])}}
    return nil if passed != @rules_stop_unless.length

    # do sampling if configured
    return nil if !@rules_sample[0].nil? && (rand * 100 >= @rules_sample[0].param1)

    # winnow sensitive details based on remove rules if configured
    @rules_remove.each {|r| details.delete_if {|d| r.scope.match(d[0])}}
    @rules_remove_unless_found.each {|r| details.delete_if {|d| r.scope.match(d[0]) && !r.param1.match(d[1])}}
    @rules_remove_if_found.each {|r| details.delete_if {|d| r.scope.match(d[0]) && r.param1.match(d[1])}}
    @rules_remove_unless.each {|r| details.delete_if {|d| r.scope.match(d[0]) && !r.param1.match(d[1])}}
    @rules_remove_if.each {|r| details.delete_if {|d| r.scope.match(d[0]) && r.param1.match(d[1])}}
    return nil if details.empty?

    # mask sensitive details based on replace rules if configured
    @rules_replace.each {|r| details.each {|d| d[1] = d[1].gsub(r.param1, r.param2) if r.scope.match(d[0])}}

    # remove any details with empty values
    details.delete_if {|d| '' == d[1]}
    return nil if details.empty?

    # finish message
    details << ['now', now.nil? ? (Time.now.to_f * 1000).floor.to_s : now]
    details << ['agent', @agent]
    details << ['host', @host]
    details << ['version', @version]
    JSON.generate details
  end

end
