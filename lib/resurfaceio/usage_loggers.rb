# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

class UsageLoggers

  @@enabled = true

  def self.disable
    @@enabled = false
  end

  def self.enable
    @@enabled = true
  end

  def self.enabled?
    @@enabled
  end

end