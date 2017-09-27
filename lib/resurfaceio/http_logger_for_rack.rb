# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'rack'
require 'resurfaceio/http_logger'

class HttpLoggerForRack # http://rack.rubyforge.org/doc/SPEC.html

  def initialize(app, options={})
    @app = app
    @logger = HttpLogger.new(options)
  end

  def call(env)
    status, headers, body = @app.call(env)
    if @logger.enabled? && (status < 300 || status == 302)
      response = Rack::Response.new(body, status, headers)
      if @logger.string_content_type?(response.content_type)
        request = Rack::Request.new(env)
        @logger.log(request, nil, response, nil)
      end
    end
    [status, headers, body]
  end

end