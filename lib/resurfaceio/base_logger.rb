# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

require 'uri'
require 'net/http'
require 'net/https'
require 'socket'
require 'zlib'
require 'resurfaceio/usage_loggers'

class BaseLogger

  def initialize(agent, options = {})
    @agent = agent
    @host = BaseLogger.host_lookup
    @skip_compression = false
    @skip_submission = false
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

    # finalize internal properties
    @enableable = !@queue.nil? || !@url.nil?
    @submit_failures = 0
    @submit_failures_lock = Mutex.new
    @submit_successes = 0
    @submit_successes_lock = Mutex.new
  end

  def agent
    @agent
  end

  def disable
    @enabled = false
    self
  end

  def enable
    @enabled = true if @enableable
    self
  end

  def enableable?
    @enableable
  end

  def enabled?
    @enabled && UsageLoggers.enabled?
  end

  def host
    @host
  end

  def queue
    @queue
  end

  def skip_compression?
    @skip_compression
  end

  def skip_compression=(value)
    @skip_compression = value
  end

  def skip_submission?
    @skip_submission
  end

  def skip_submission=(value)
    @skip_submission = value
  end

  def submit(msg)
    if msg.nil? || @skip_submission || !enabled?
      # do nothing
    elsif @queue
      @queue << msg
      @submit_successes_lock.synchronize { @submit_successes += 1 }
    else
      begin
        @url_parsed ||= URI.parse(@url)
        @url_connection ||= Net::HTTP.new(@url_parsed.host, @url_parsed.port)
        @url_connection.use_ssl = @url.include?('https')
        request = Net::HTTP::Post.new(@url_parsed.path)
        if @skip_compression
          request.body = msg
        else
          request.add_field('Content-Encoding', 'deflated')
          request.body = Zlib::Deflate.deflate(msg)
        end
        response = @url_connection.request(request)
        if response.code.to_i == 204
          @submit_successes_lock.synchronize { @submit_successes += 1 }
        else
          @submit_failures_lock.synchronize { @submit_failures += 1 }
        end
      rescue SocketError
        @submit_failures_lock.synchronize { @submit_failures += 1 }
        @url_connection = nil
      end
    end
  end

  def submit_failures
    @submit_failures
  end

  def submit_successes
    @submit_successes
  end

  def url
    @url
  end

  def version
    @version
  end

  def self.host_lookup
    dyno = ENV['DYNO']
    return dyno unless dyno.nil?
    begin
      Socket.gethostname
    rescue
      'unknown'
    end
  end

  def self.version_lookup
    Gem.loaded_specs['resurfaceio-logger'].version.to_s
  end

end
