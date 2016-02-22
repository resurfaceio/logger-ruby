# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'uri'
require 'net/http'
require 'net/https'
require 'resurfaceio/json_message'

class HttpLogger

  SOURCE = 'resurfaceio-logger-ruby'

  URL = 'https://resurfaceio.herokuapp.com/messages'

  def initialize(url = URL, enabled = true)
    @enabled = enabled
    @url = url
    @version = HttpLogger.version_lookup
  end

  def disable
    @enabled = false
  end

  def enable
    @enabled = true
  end

  def format_echo(json, now)
    JsonMessage.start(json, 'echo', SOURCE, version, now)
    JsonMessage.finish(json)
  end

  def format_request(json, now, request)
    JsonMessage.start(json, 'http_request', SOURCE, version, now) << ','
    JsonMessage.append(json, 'url', request.url)
    JsonMessage.finish(json)
  end

  def format_response(json, now, response)
    JsonMessage.start(json, 'http_response', SOURCE, version, now) << ','
    JsonMessage.append(json, 'code', response.status)
    JsonMessage.finish(json)
  end

  def is_enabled?
    @enabled
  end

  def log_echo
    @enabled ? post(format_echo(String.new, Time.now.to_i)).eql?(200) : true
  end

  def log_request(request)
    @enabled ? post(format_request(String.new, Time.now.to_i, request)).eql?(200) : true
  end

  def log_response(response)
    @enabled ? post(format_response(String.new, Time.now.to_i, response)).eql?(200) : true
  end

  def post(body)
    begin
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.path)
      request.body = body
      response = https.request(request)
      response.code.to_i
    rescue SocketError
      404
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
