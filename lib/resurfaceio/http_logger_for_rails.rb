# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/http_logger_factory'

class HttpLoggerForRails

  def initialize
    @logger = HttpLoggerFactory.get
  end

  def around(controller)
    begin
      yield
    ensure
      if @logger.active?
        @logger.log_request(controller.request)
        @logger.log_response(controller.response)
      end
    end
  end

end