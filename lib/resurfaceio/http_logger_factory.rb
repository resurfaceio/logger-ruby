# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/http_logger'

class HttpLoggerFactory

  @@default_logger = HttpLogger.new

  def self.get
    @@default_logger
  end

end