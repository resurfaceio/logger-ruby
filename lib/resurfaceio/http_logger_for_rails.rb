# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/http_logger_factory'

class HttpLoggerForRails

  def before(controller)
    HttpLoggerFactory.get.log_request(controller.request)
  end

  def after(controller)
    HttpLoggerFactory.get.log_response(controller.response)
  end

  def around(controller)
    before(controller)
    begin
      yield
    ensure
      after(controller)
    end
  end

end