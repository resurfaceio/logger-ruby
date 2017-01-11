# coding: utf-8
# © 2016-2017 Resurface Labs LLC

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