# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

require 'resurfaceio/http_logger'

class HttpLoggerForRails

  def initialize(options = {})
    @logger = HttpLogger.new(options)
  end

  def logger
    @logger
  end

  def around(controller)
    yield
    if @logger.enabled?
      request = controller.request
      response = controller.response
      status = response.status
      if (status < 300 || status == 302) && HttpLogger::string_content_type?(response.content_type)
        @logger.submit(@logger.format(request, response))
      end
    end
  end

end