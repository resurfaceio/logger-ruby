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
      @logger.log(controller.request, nil, controller.response, nil)
    end
  end

end