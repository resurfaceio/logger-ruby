# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/http_logger'

class HttpLoggerFactory

  @@default = HttpLogger.new

  def self.get
    @@default
  end

end