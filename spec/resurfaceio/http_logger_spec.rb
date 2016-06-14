# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLogger do

  it 'uses module namespace' do
    expect(HttpLogger.class.equal?(Resurfaceio::HttpLogger.class)).to be true
    expect(Resurfaceio::HttpLogger.version_lookup).to eql(HttpLogger.version_lookup)
  end

  it 'uses agent' do
    agent = HttpLogger::AGENT
    expect(agent).to be_kind_of String
    expect(agent).not_to be nil
    expect(agent.length).to be > 0
    expect(agent.end_with?('.rb')).to be true
    expect(agent.include?('\\')).to be false
    expect(agent.include?('\"')).to be false
    expect(agent.include?('\'')).to be false
  end

  it 'appends request' do
    json = HttpLogger.new.append_to_buffer(String.new, 1455908640173, mock_request, nil, mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("\"agent\":\"#{HttpLogger::AGENT}\"")).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"now\":\"1455908640173\"")).to be true
    expect(json.include?("\"request_body\"")).to be false
    expect(json.include?("\"request_headers\":[]")).to be true
    expect(json.include?("\"request_method\":\"GET\"")).to be true
    expect(json.include?("\"request_url\":\"#{MOCK_URL}\"")).to be true
    expect(json.include?("\"version\":\"#{HttpLogger.version_lookup}\"")).to be true
  end

  it 'formats request with body' do
    json = HttpLogger.new.format(mock_request_with_body, nil, mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("\"agent\":\"#{HttpLogger::AGENT}\"")).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"request_body\":\"#{MOCK_JSON_ESCAPED}\"")).to be true
    expect(json.include?("\"request_headers\":[{\"content-type\":\"application/json\"}]")).to be true
    expect(json.include?("\"request_method\":\"POST\"")).to be true
    expect(json.include?("\"request_url\":\"#{MOCK_URL}\"")).to be true
    expect(json.include?("\"version\":\"#{HttpLogger.version_lookup}\"")).to be true
  end

  it 'formats request with empty body' do
    json = HttpLogger.new.format(mock_request_with_body2, '', mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("\"agent\":\"#{HttpLogger::AGENT}\"")).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"request_body\":\"\"")).to be true
    expect(json.include?("\"request_headers\":[{\"content-type\":\"application/json\"},{\"abc\":\"123\"}]")).to be true
    expect(json.include?("\"request_method\":\"POST\"")).to be true
    expect(json.include?("\"request_url\":\"#{MOCK_URL}\"")).to be true
    expect(json.include?("\"version\":\"#{HttpLogger.version_lookup}\"")).to be true
  end

  it 'formats request with alternative body' do
    json = HttpLogger.new.format(mock_request_with_body2, MOCK_JSON_ALT, mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("\"agent\":\"#{HttpLogger::AGENT}\"")).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"request_body\":\"#{MOCK_JSON_ALT_ESCAPED}\"")).to be true
    expect(json.include?("\"request_headers\":[{\"content-type\":\"application/json\"},{\"abc\":\"123\"}]")).to be true
    expect(json.include?("\"request_method\":\"POST\"")).to be true
    expect(json.include?("\"request_url\":\"#{MOCK_URL}\"")).to be true
    expect(json.include?("\"version\":\"#{HttpLogger.version_lookup}\"")).to be true
  end

  it 'formats response' do
    json = HttpLogger.new.format(mock_request, nil, mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("\"agent\":\"#{HttpLogger::AGENT}\"")).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"response_body\"")).to be false
    expect(json.include?("\"response_code\":\"200\"")).to be true
    expect(json.include?("\"response_headers\":[]")).to be true
    expect(json.include?("\"version\":\"#{HttpLogger.version_lookup}\"")).to be true
  end

  it 'formats response with body' do
    json = HttpLogger.new.format(mock_request, nil, mock_response_with_body, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("\"agent\":\"#{HttpLogger::AGENT}\"")).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"response_body\":\"#{MOCK_HTML_ESCAPED}\"")).to be true
    expect(json.include?("\"response_code\":\"200\"")).to be true
    expect(json.include?("\"response_headers\":[]")).to be true
    expect(json.include?("\"version\":\"#{HttpLogger.version_lookup}\"")).to be true
  end

  it 'formats response with empty body' do
    json = HttpLogger.new.format(mock_request, nil, mock_response_with_body, '')
    expect(parseable?(json)).to be true
    expect(json.include?("\"agent\":\"#{HttpLogger::AGENT}\"")).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"response_body\":\"\"")).to be true
    expect(json.include?("\"response_code\":\"200\"")).to be true
    expect(json.include?("\"response_headers\":[]")).to be true
    expect(json.include?("\"version\":\"#{HttpLogger.version_lookup}\"")).to be true
  end

  it 'formats response with alternate body' do
    json = HttpLogger.new.format(mock_request, nil, mock_response_with_body, MOCK_HTML_ALT)
    expect(parseable?(json)).to be true
    expect(json.include?("\"agent\":\"#{HttpLogger::AGENT}\"")).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"response_body\":\"#{MOCK_HTML_ALT_ESCAPED}\"")).to be true
    expect(json.include?("\"response_code\":\"200\"")).to be true
    expect(json.include?("\"response_headers\":[]")).to be true
    expect(json.include?("\"version\":\"#{HttpLogger.version_lookup}\"")).to be true
  end

  it 'skips logging when disabled' do
    MOCK_INVALID_URLS.each do |url|
      logger = HttpLogger.new(url, false)
      expect(logger.log(nil, nil, nil, nil)).to be true
      expect(logger.submit(nil)).to be true
      expect(logger.tracing_history.length).to be 0
    end
  end

  it 'submits to good url' do
    logger = HttpLogger.new
    json = String.new
    JsonMessage.start(json, 'echo', logger.agent, logger.version, Time.now.to_i)
    JsonMessage.stop(json)
    expect(logger.submit(json)).to be true
    expect(logger.tracing_history.length).to be 0
  end

  it 'submits to invalid url' do
    MOCK_INVALID_URLS.each do |url|
      logger = HttpLogger.new(url)
      expect(logger.submit('TEST-ABC')).to be false
      expect(logger.tracing_history.length).to be 0
    end
  end

  it 'uses tracing' do
    logger = HttpLogger.new.disable
    expect(logger.active?).to be false
    expect(logger.enabled?).to be false
    expect(logger.tracing?).to be false
    expect(logger.tracing_history.length).to be 0
    logger.tracing_start
    begin
      expect(logger.active?).to be true
      expect(logger.tracing?).to be true
      expect(logger.tracing_history.length).to be 0
      expect(logger.submit('TEST-123')).to be true
      expect(logger.tracing_history.length).to eql(1)
      expect(logger.submit('TEST-234')).to be true
      expect(logger.tracing_history.length).to eql(2)
      expect(logger.submit('TEST-345')).to be true
      expect(logger.tracing_history.length).to eql(3)
    ensure
      logger.tracing_stop.enable
      expect(logger.active?).to be true
      expect(logger.enabled?).to be true
      expect(logger.tracing?).to be false
      expect(logger.tracing_history.length).to be 0
    end
  end

  it 'uses url' do
    url = HttpLogger::DEFAULT_URL
    expect(url).to be_kind_of String
    expect(url).not_to be nil
    expect(url.length).to be > 0
    expect(url.start_with?('https://')).to be true
    expect(url.include?('\\')).to be false
    expect(url.include?('\"')).to be false
    expect(url.include?('\'')).to be false
    expect(HttpLogger.new.url).to eql(HttpLogger::DEFAULT_URL)
    expect(HttpLogger.new('https://foobar.com').url).to eql('https://foobar.com')
  end

  it 'uses version' do
    version = HttpLogger.version_lookup
    expect(version).to be_kind_of String
    expect(version).not_to be nil
    expect(version.length).to be > 0
    expect(version.start_with?('1.3.')).to be true
    expect(version.include?('\\')).to be false
    expect(version.include?('\"')).to be false
    expect(version.include?('\'')).to be false
    expect(HttpLogger.new.version).to eql(HttpLogger.version_lookup)
  end

end
