# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/http_logger'

class HttpLoggerForRails

  def initialize(options={})
    @logger = HttpLogger.new(options)
  end

  def around(controller)
    yield
    @logger.log(controller.request, nil, controller.response, nil)
  end

end