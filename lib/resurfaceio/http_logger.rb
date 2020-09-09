# coding: utf-8
# © 2016-2020 Resurface Labs Inc.

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

    # submit metadata message
    if @enabled
      message = []
      message << %w[message_type metadata]
      message << ['agent', @agent]
      message << ['host', @host]
      message << ['version', @version]
      message << ['metadata_id', metadata_id]
      submit(JSON.generate(message))
    end
  end

  def rules
    @rules
  end

  def submit_if_passing(details)
    details = @rules.apply(details)
    return nil if details.nil?
    details << ['metadata_id', @metadata_id]
    submit(JSON.generate(details))
  end

  def self.string_content_type?(s)
    !s.nil? && !(s =~ /^(text\/(html|plain|xml))|(application\/(json|soap|xml|x-www-form-urlencoded))/i).nil?
  end
end
