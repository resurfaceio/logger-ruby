# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

class UsageLoggers

  @@DISABLED = 'true'.eql?(ENV['USAGE_LOGGERS_DISABLE'])

  @@disabled = @@DISABLED

  def self.disable
    @@disabled = true
  end

  def self.enable
    @@disabled = false unless @@DISABLED
  end

  def self.enabled?
    !@@disabled
  end

  def self.url_by_default
    ENV['USAGE_LOGGERS_URL']
  end

end