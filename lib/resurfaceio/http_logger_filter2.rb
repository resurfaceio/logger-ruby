# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'rack'
require 'resurfaceio/http_logger_factory'

class HttpLoggerFilter2

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    HttpLoggerFactory.get.log_request(request)
    status, headers, body = @app.call(env)
    response = Rack::Response.new(body, status, headers)
    HttpLoggerFactory.get.log_response(response)
    [status, headers, body]
  end

end