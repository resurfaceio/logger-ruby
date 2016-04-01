# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'
require_relative 'mocks'

describe HttpLoggerForRack do

  it 'uses module namespace' do
    expect(HttpLoggerForRack.class.equal?(Resurfaceio::HttpLoggerForRack.class)).to be true
  end

  it 'logs rack calls' do
    logger = HttpLoggerFactory.get.disable.tracing_start
    begin
      filter = HttpLoggerForRack.new(MockHtmlApp.new)
      filter.call(MOCK_ENV)
      expect(logger.tracing_history.length).to eql(2) # todo check tracing history

      filter = HttpLoggerForRack.new(MockJsonApp.new)
      filter.call(MOCK_ENV)
      expect(logger.tracing_history.length).to eql(4) # todo check tracing history
    ensure
      logger.tracing_stop.enable
    end
  end

  it 'skips logging for redirects and unmatched content types' do
    logger = HttpLoggerFactory.get.disable.tracing_start
    begin
      filter = HttpLoggerForRack.new(MockCustomApp.new)
      filter.call(MOCK_ENV)
      expect(logger.tracing_history.length).to eql(0)

      filter = HttpLoggerForRack.new(MockCustomRedirectingApp.new)
      filter.call(MOCK_ENV)
      expect(logger.tracing_history.length).to eql(0)

      filter = HttpLoggerForRack.new(MockHtmlRedirectingApp.new)
      filter.call(MOCK_ENV)
      expect(logger.tracing_history.length).to eql(0)
    ensure
      logger.tracing_stop.enable
    end
  end

end
