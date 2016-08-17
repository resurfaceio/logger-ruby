# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/all'

describe UsageLoggers do

  it 'uses module namespace' do
    expect(UsageLoggers.class.equal?(Resurfaceio::UsageLoggers.class)).to be true
  end

  it 'enables and disables all loggers' do
    logger = HttpLogger.new(url: UsageLoggers.url_for_demo)
    expect(logger.enabled?).to be true
    UsageLoggers.disable
    expect(UsageLoggers.enabled?).to be false
    expect(logger.enabled?).to be false
    UsageLoggers.enable
    expect(UsageLoggers.enabled?).to be true
    expect(logger.enabled?).to be true
  end

  it 'returns url for demo' do
    url = UsageLoggers.url_for_demo
    expect(url).to be_kind_of String
    expect(url.length).to be > 0
    expect(HttpLogger.new(url: url).enabled?).to be true
  end

end