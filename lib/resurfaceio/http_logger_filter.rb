# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/http_logger_factory'

class HttpLoggerFilter

  def self.before(controller)
    HttpLoggerFactory.get.log_request(controller.request)
  end

  def self.after(controller)
    HttpLoggerFactory.get.log_response(controller.response)
  end

end