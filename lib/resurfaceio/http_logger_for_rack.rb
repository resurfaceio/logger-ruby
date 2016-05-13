# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'rack'
require 'resurfaceio/http_logger_factory'

class HttpLoggerForRack # http://rack.rubyforge.org/doc/SPEC.html

  def initialize(app)
    @app = app
    @logger = HttpLoggerFactory.get
  end

  def call(env)
    status, headers, body = @app.call(env)
    if @logger.active? && status != 304
      response = Rack::Response.new(body, status, headers)
      if string_content_type?(response.content_type)
        request = Rack::Request.new(env)
        @logger.log_request(request)
        @logger.log_response(response)
      end
    end
    [status, headers, body]
  end

  protected

  def string_content_type?(s)
    !s.nil? && (s.include?('text/html') || s.include?('text/plain') || s.include?('text/xml') ||
        s.include?('application/json') || s.include?('application/soap+xml') ||
        s.include?('application/xml') || s.include?('application/x-www-form-urlencoded'))
  end

end