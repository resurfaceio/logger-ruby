# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/http_logger'
require 'resurfaceio/http_logger_factory'
require 'resurfaceio/http_logger_for_rack'
require 'resurfaceio/http_logger_for_rails'
require 'resurfaceio/http_request_impl'
require 'resurfaceio/http_response_impl'
require 'resurfaceio/json_message'

module Resurfaceio

  class HttpLoggerFactory < HttpLoggerFactory
  end

  class HttpLoggerForRack < HttpLoggerForRack
  end

  class HttpLoggerForRails < HttpLoggerForRails
  end

  class HttpLogger < HttpLogger
  end

  class HttpRequestImpl < HttpRequestImpl
  end

  class HttpResponseImpl < HttpResponseImpl
  end

  class JsonMessage < JsonMessage
  end

end
