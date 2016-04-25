# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'uri'
require 'net/http'
require 'net/https'

class UsageLogger

  DEFAULT_URL = 'https://resurfaceio.herokuapp.com/messages'

  def initialize(url = DEFAULT_URL, enabled = true)
    @enabled = enabled
    @tracing = false
    @tracing_history = []
    @url = url
    @version = HttpLogger.version_lookup
  end

  def active?
    @enabled || @tracing
  end

  def disable
    @enabled = false
    self
  end

  def enable
    @enabled = true
    self
  end

  def enabled?
    @enabled
  end

  def tracing?
    @tracing
  end

  def tracing_history
    @tracing_history
  end

  def tracing_start
    @tracing = true
    @tracing_history = []
    self
  end

  def tracing_stop
    @tracing = false
    @tracing_history = []
    self
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

  protected

  def post(json)
    if @tracing
      @tracing_history << json
      true
    else
      begin
        uri = URI.parse(url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(uri.path)
        request.body = json
        response = https.request(request)
        response.code.to_i == 200
      rescue SocketError
        false
      end
    end
  end

end
