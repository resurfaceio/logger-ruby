# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

class UsageLoggers

  @@enabled = !ENV['USAGE_LOGGERS_DISABLED'].eql?('true')

  def self.demo_url
    'https://demo-resurfaceio.herokuapp.com/messages'
  end

  def self.disable
    @@enabled = false
  end

  def self.enable
    @@enabled = true unless ENV['USAGE_LOGGERS_DISABLED'].eql?('true')
  end

  def self.enabled?
    @@enabled
  end

end