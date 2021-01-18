# coding: utf-8
# © 2016-2021 Resurface Labs Inc.

class Timer

  def initialize
    @started = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
  end

  def millis
    (Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond) - @started).to_s
  end

end