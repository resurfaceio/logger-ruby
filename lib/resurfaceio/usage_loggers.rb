# coding: utf-8
# © 2016-2017 Resurface Labs LLC

class UsageLoggers

  @@disabled = 'true'.eql?(ENV['USAGE_LOGGERS_DISABLE'])

  def self.disable
    @@disabled = true
  end

  def self.enable
    @@disabled = false unless 'true'.eql?(ENV['USAGE_LOGGERS_DISABLE'])
  end

  def self.enabled?
    !@@disabled
  end

  def self.url_by_default
    ENV['USAGE_LOGGERS_URL']
  end

  def self.url_for_demo
    'https://demo-resurfaceio.herokuapp.com/messages'
  end

end