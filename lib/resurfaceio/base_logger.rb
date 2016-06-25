# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'uri'
require 'net/http'
require 'net/https'
require 'resurfaceio/usage_loggers'

class BaseLogger

  def initialize(agent, options={})
    @agent = agent
    @version = BaseLogger.version_lookup

    # detect options in priority order
    @enabled = options.fetch(:enabled, true)
    if options.has_key?(:queue)
      @queue = options[:queue]
    elsif options.has_key?(:url)
      @url = options[:url]
      @url = UsageLoggers.demo_url if @url.eql?('DEMO')
    elsif ENV.has_key?('USAGE_LOGGERS_URL')
      @url = ENV['USAGE_LOGGERS_URL']
    else
      @enabled = false
    end

    # validate url when present
    begin
      raise Exception unless @url.nil? || URI.parse(@url).scheme.eql?('https')
    rescue Exception
      @url = nil
      @enabled = false
    end
  end

  def agent
    @agent
  end

  def disable
    @enabled = false
    self
  end

  def enable
    @enabled = true unless @queue.nil? && @url.nil?
    self
  end

  def enabled?
    @enabled && UsageLoggers.enabled?
  end

  def submit(json)
    if !enabled?
      true
    elsif @queue
      @queue << json
      true
    else
      begin
        @uri ||= URI.parse(@url)
        @connection ||= Net::HTTP.new(@uri.host, @uri.port)
        @connection.use_ssl = true
        request = Net::HTTP::Post.new(@uri.path)
        request.body = json
        response = @connection.request(request)
        response.code.to_i == 200
      rescue SocketError
        @connection = nil
        false
      end
    end
  end

  def url
    @url
  end

  def version
    @version
  end

  def self.version_lookup
    Gem.loaded_specs['resurfaceio-logger'].version.to_s
  end

end
