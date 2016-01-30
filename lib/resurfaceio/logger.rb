# coding: utf-8
# Copyright (c) 2016 Resurface Labs, All Rights Reserved

module Resurfaceio
  class Logger
    def self.version
      Gem.loaded_specs['resurfaceio-logger'].version.to_s
    end
  end
end
