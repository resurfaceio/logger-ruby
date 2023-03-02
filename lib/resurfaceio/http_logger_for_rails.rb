# coding: utf-8
# © 2016-2023 Resurface Labs Inc.

require 'resurfaceio/http_logger'
require 'resurfaceio/http_message'
require 'resurfaceio/timer'

class HttpLoggerForRails

  def initialize(options = {})
    @logger = HttpLogger.new(options)
  end

  def logger
    @logger
  end

  def around(controller)
    timer = Timer.new
    yield
    if @logger.enabled?
      request = controller.request
      response = controller.response
      HttpMessage.send(logger, request, response, nil, nil, nil, timer.millis)
    end
  end

end