# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLoggerForRack do

  it 'uses module namespace' do
    expect(HttpLoggerForRack.class.equal?(Resurfaceio::HttpLoggerForRack.class)).to be true
  end

  it 'logs html' do
    logger = HttpLoggerFactory.get.disable.tracing_start
    begin
      HttpLoggerForRack.new(MockHtmlApp.new).call(MOCK_ENV)
      expect(logger.tracing_history.length).to eql(2)
      json = logger.tracing_history[0]
      expect(parseable?(json)).to be true
      expect(json.include?("\"body\"")).to be false
      expect(json.include?("\"category\":\"http_request\"")).to be true
      expect(json.include?("\"headers\":[#{MOCK_HEADERS_ESCAPED}]")).to be true
      expect(json.include?("\"method\":\"GET\"")).to be true
      expect(json.include?("\"url\":\"#{MOCK_URL}\"")).to be true
      json = logger.tracing_history[1]
      expect(parseable?(json)).to be true
      expect(json.include?("\"body\":\"#{MOCK_HTML_ESCAPED}\"")).to be true
      expect(json.include?("\"category\":\"http_response\"")).to be true
      expect(json.include?("\"code\":\"200\"")).to be true
      expect(json.include?("\"headers\":[{\"content-type\":\"text/html\"},{\"a\":\"1\"},{\"content-length\":\"25\"}]")).to be true
    ensure
      logger.tracing_stop.enable
    end
  end

  it 'logs json' do
    logger = HttpLoggerFactory.get.disable.tracing_start
    begin
      HttpLoggerForRack.new(MockJsonApp.new).call(MOCK_ENV)
      expect(logger.tracing_history.length).to eql(2)
      json = logger.tracing_history[0]
      expect(parseable?(json)).to be true
      expect(json.include?("\"body\"")).to be false
      expect(json.include?("\"category\":\"http_request\"")).to be true
      expect(json.include?("\"headers\":[#{MOCK_HEADERS_ESCAPED}]")).to be true
      expect(json.include?("\"method\":\"GET\"")).to be true
      expect(json.include?("\"url\":\"#{MOCK_URL}\"")).to be true
      json = logger.tracing_history[1]
      expect(parseable?(json)).to be true
      expect(json.include?("\"body\":\"#{MOCK_JSON_ESCAPED}\"")).to be true
      expect(json.include?("\"category\":\"http_response\"")).to be true
      expect(json.include?("\"code\":\"200\"")).to be true
      expect(json.include?("\"headers\":[{\"content-type\":\"application/json\"},{\"content-length\":\"21\"}]")).to be true
    ensure
      logger.tracing_stop.enable
    end
  end

  it 'logs json post' do
    logger = HttpLoggerFactory.get.disable.tracing_start
    begin
      HttpLoggerForRack.new(MockJsonApp.new).call(MOCK_JSON_ENV)
      expect(logger.tracing_history.length).to eql(2)
      json = logger.tracing_history[0]
      expect(parseable?(json)).to be true
      expect(json.include?("\"body\":\"#{MOCK_JSON_ESCAPED}\"")).to be true
      expect(json.include?("\"category\":\"http_request\"")).to be true
      expect(json.include?("\"headers\":[#{MOCK_JSON_ENV_ESCAPED}]")).to be true
      expect(json.include?("\"method\":\"POST\"")).to be true
      expect(json.include?("\"url\":\"#{MOCK_URL}\"")).to be true
      json = logger.tracing_history[1]
      expect(parseable?(json)).to be true
      expect(json.include?("\"body\":\"#{MOCK_JSON_ESCAPED}\"")).to be true
      expect(json.include?("\"category\":\"http_response\"")).to be true
      expect(json.include?("\"code\":\"200\"")).to be true
      expect(json.include?("\"headers\":[{\"content-type\":\"application/json\"},{\"content-length\":\"21\"}]")).to be true
    ensure
      logger.tracing_stop.enable
    end
  end

  it 'skips logging for redirects and unmatched content types' do
    logger = HttpLoggerFactory.get.disable.tracing_start
    begin
      apps = [MockCustomApp.new, MockCustomRedirectApp.new, MockHtmlRedirectApp.new]
      apps.each do |app|
        HttpLoggerForRack.new(app).call(MOCK_ENV)
        expect(logger.tracing_history.length).to eql(0)
      end
    ensure
      logger.tracing_stop.enable
    end
  end

end
