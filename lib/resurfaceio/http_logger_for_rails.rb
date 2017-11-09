# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'resurfaceio/http_logger'

class HttpLoggerForRails

  def initialize(options={})
    @logger = HttpLogger.new(options)
  end

  def around(controller)
    yield
    request = controller.request
    response = controller.response
    status = response.status
    if (status < 300 || status == 302) && HttpLogger::string_content_type?(response.content_type)
      @logger.log(request, response)
    end
  end

end