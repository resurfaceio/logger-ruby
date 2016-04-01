# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'rack'
require 'resurfaceio/http_logger_factory'

class HttpLoggerForRack # http://rack.rubyforge.org/doc/SPEC.html

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    if status != 304
      response = Rack::Response.new(body, status, headers)
      content_type = response.content_type
      unless content_type.nil?
        content_type = content_type.downcase
        is_html = content_type.include?('text/html')
        is_json = content_type.include?('application/json')
        is_soap = content_type.include?('application/soap+xml')
        is_xml1 = content_type.include?('application/xml')
        is_xml2 = content_type.include?('text/xml')
        if is_html || is_json || is_soap || is_xml1 || is_xml2
          request = Rack::Request.new(env)
          HttpLoggerFactory.get.log_request(request)
          HttpLoggerFactory.get.log_response(response)
        end
      end
    end
    [status, headers, body]
  end

end