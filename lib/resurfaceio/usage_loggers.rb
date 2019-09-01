# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

class UsageLoggers

  @@BRICKED = 'true'.eql?(ENV['USAGE_LOGGERS_DISABLE'])

  @@disabled = @@BRICKED

  def self.disable
    @@disabled = true
  end

  def self.enable
    @@disabled = false unless @@BRICKED
  end

  def self.enabled?
    !@@disabled
  end

  def self.url_by_default
    ENV['USAGE_LOGGERS_URL']
  end

end