# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'uri'
require 'net/http'
require 'net/https'
require 'zlib'
require 'resurfaceio/usage_loggers'

class BaseLogger

  def initialize(agent, options = {})
    @agent = agent
    @skip_compression = false
    @version = BaseLogger.version_lookup

    # set options in priority order
    if options.respond_to?(:fetch) && options.respond_to?(:has_key?)
      @enabled = options.fetch(:enabled, true)
      if options.has_key?(:queue)
        @queue = options[:queue]
      elsif options.has_key?(:url)
        url = options[:url]
        if url.nil?
          @url = UsageLoggers.url_by_default
        else
          @url = url
        end
        @enabled = false if url.nil?
      else
        @url = UsageLoggers.url_by_default
        @enabled = false if @url.nil?
      end
    elsif options.respond_to?(:to_s)
      @url = options.to_s
      @enabled = @url.nil? ? false : true
    else
      @enabled = false
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

  def skip_compression?
    @skip_compression
  end

  def skip_compression=(value)
    @skip_compression = value
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
        if @skip_compression
          request.body = json
        else
          request.add_field('Content-Encoding', 'deflated')
          request.body = Zlib::Deflate.deflate(json)
        end
        response = @url_connection.request(request)
        response.code.to_i == 204
      rescue SocketError
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
