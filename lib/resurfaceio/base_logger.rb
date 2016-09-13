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

    # set options in priority order
    @enabled = options.fetch(:enabled, true)
    if options.has_key?(:queue)
      @queue = options[:queue]
    elsif options.has_key?(:url)
      url = options[:url]
      if url.nil?
        @url = UsageLoggers.url_by_default
        @enabled = false if @url.nil?
      elsif url.eql?('DEMO')
        @url = UsageLoggers.url_for_demo
      else
        @url = url
      end
    else
      @url = UsageLoggers.url_by_default
      @enabled = false if @url.nil?
    end

    # validate url when present
    unless @url.nil?
      begin
        raise Exception unless URI.parse(@url).scheme.include?('http')
      rescue Exception
        @url = nil
        @enabled = false
      end
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
        @url_parsed ||= URI.parse(@url)
        @url_connection ||= Net::HTTP.new(@url_parsed.host, @url_parsed.port)
        @url_connection.use_ssl = @url.include?('https')
        request = Net::HTTP::Post.new(@url_parsed.path)
        request.body = json
        response = @url_connection.request(request)
        response.code.to_i == 200
      rescue SocketError
        # todo retry?
        @url_connection = nil
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
