# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/all'

describe UsageLoggers do

  it 'uses module namespace' do
    expect(UsageLoggers.class.equal?(Resurfaceio::UsageLoggers.class)).to be true
  end

  it 'uses enabled state to control other loggers' do
    UsageLoggers.disable
    expect(UsageLoggers.enabled?).to be false
    expect(HttpLogger.new.active?).to be false
    expect(HttpLogger.new.enabled?).to be true
    UsageLoggers.enable
    expect(UsageLoggers.enabled?).to be true
    expect(HttpLogger.new.active?).to be true
    expect(HttpLogger.new.enabled?).to be true
  end

end
