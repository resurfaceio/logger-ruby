# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'
require_relative 'mocks'

describe HttpLoggerForRails do

  it 'uses module namespace' do
    expect(HttpLoggerForRails.class.equal?(Resurfaceio::HttpLoggerForRails.class)).to be true
  end

  it 'logs controller call' do
    logger = HttpLoggerFactory.get.disable.tracing_start
    begin
      HttpLoggerForRails.new.around(MockController.new) {}
      expect(logger.tracing_history.length).to eql(2)
      expect(logger.tracing_history[0].include?("{\"category\":\"http_request\",")).to be true
      expect(logger.tracing_history[0].include?("\"url\":\"#{MOCK_URL}\"}")).to be true
      expect(logger.tracing_history[1].include?("{\"category\":\"http_response\",")).to be true
      expect(logger.tracing_history[1].include?("\"code\":200",)).to be true
      expect(logger.tracing_history[1].include?("\"body\":\"#{MOCK_HTML_ESCAPED}\"}")).to be true
    ensure
      logger.tracing_stop.enable
    end
  end

end
