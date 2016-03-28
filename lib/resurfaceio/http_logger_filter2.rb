# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/http_logger_factory'

class HttpLoggerFilter2

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    HttpLoggerFactory.get # do logging here
    [status, headers, body]
  end

end