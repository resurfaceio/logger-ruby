# coding: utf-8
# © 2016-2021 Resurface Labs Inc.

require 'rack'
require 'resurfaceio/http_logger'
require 'resurfaceio/http_message'
require 'resurfaceio/timer'

class HttpLoggerForRack # http://rack.rubyforge.org/doc/SPEC.html

  def initialize(app, options = {})
    @app = app
    @logger = HttpLogger.new(options)
  end

  def logger
    @logger
  end

  def call(env)
    timer = Timer.new
    status, headers, body = @app.call(env)
    if @logger.enabled? && (status < 300 || status == 302)
      response = Rack::Response.new(body, status, headers)
      if HttpLogger::string_content_type?(response.content_type)
        request = Rack::Request.new(env)
        HttpMessage.send(logger, request, response, nil, nil, nil, timer.millis)
      end
    end
    [status, headers, body]
  end

end