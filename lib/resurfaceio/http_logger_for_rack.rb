# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'rack'
require 'resurfaceio/http_logger_factory'

class HttpLoggerForRack

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    if status != 304
      response = Rack::Response.new(body, status, headers)
      content_type = response.content_type
      is_html = content_type.present? && (content_type.downcase.index('text/html') == 0)
      if is_html
        request = Rack::Request.new(env)
        HttpLoggerFactory.get.log_request(request)
        HttpLoggerFactory.get.log_response(response)
      end
    end
    [status, headers, body]
  end

end