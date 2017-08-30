# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'resurfaceio/http_logger'

class HttpLoggerForRails

  def initialize(options={})
    @logger = HttpLogger.new(options)
  end

  def around(controller)
    yield
    response = controller.response
    if response.status < 300 && @logger.string_content_type?(response.content_type)
      @logger.log(controller.request, nil, response, nil)
    end
  end

end