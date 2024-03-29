# coding: utf-8
# © 2016-2024 Graylog, Inc.

require 'json'
require 'resurfaceio/base_logger'
require 'resurfaceio/http_message'
require 'resurfaceio/http_rule'
require 'resurfaceio/http_rules'

class HttpLogger < BaseLogger

  AGENT = 'http_logger.rb'.freeze

  def initialize(options = {})
    super(AGENT, options)

    # parse specified rules
    if options.respond_to?(:has_key?) && options.has_key?(:rules)
      @rules = HttpRules.new(options[:rules])
    else
      @rules = HttpRules.new(nil)
    end

    # apply configuration rules
    @skip_compression = @rules.skip_compression
    @skip_submission = @rules.skip_submission
    unless @url.nil? || @url.start_with?('https') || @rules.allow_http_url
      @enableable = false
      @enabled = false
    end
  end

  def rules
    @rules
  end

  def submit_if_passing(details)
    # apply active rules
    details = @rules.apply(details)
    return nil if details.nil?

    # finalize message
    details << ['host', @host]

    # let's do this thing
    submit(JSON.generate(details))
  end

end
