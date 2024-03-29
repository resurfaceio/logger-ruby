# coding: utf-8
# © 2016-2024 Graylog, Inc.

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
    if @logger.enabled?
      response = Rack::Response.new(body, status, headers)
      request = Rack::Request.new(env)
      HttpMessage.send(logger, request, response, nil, nil, nil, timer.millis)
    end
    [status, headers, body]
  end

end