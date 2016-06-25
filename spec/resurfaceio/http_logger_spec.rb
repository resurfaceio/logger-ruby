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

  it 'performs enabling when expected' do
    logger = HttpLogger.new(url: 'DEMO', enabled: false)
    expect(logger.enabled?).to be false
    logger.enable
    expect(logger.enabled?).to be true

    logger = HttpLogger.new(queue: [], enabled: false)
    expect(logger.enabled?).to be false
    logger.enable.disable.enable
    expect(logger.enabled?).to be true

    logger = HttpLogger.new(url: UsageLoggers.demo_url, enabled: false)
    expect(logger.enabled?).to be false
    logger.enable.disable.enable.disable.disable.disable.enable
    expect(logger.enabled?).to be true
  end

  it 'skips enabling for invalid urls' do
    URLS_INVALID.each do |url|
      logger = HttpLogger.new(url: url)
      expect(logger.enabled?).to be false
      logger.enable
      expect(logger.enabled?).to be false
    end
  end

  it 'skips enabling for missing url' do
    logger = HttpLogger.new
    expect(logger.enabled?).to be false
    logger.enable
    expect(logger.enabled?).to be false
  end

  it 'skips logging when disabled' do
    URLS_UNRESOLVABLE.each do |url|
      logger = HttpLogger.new(url: url).disable
      expect(logger.log(nil, nil, nil, nil)).to be true
    end
  end

  it 'submits to demo url' do
    logger = HttpLogger.new(url: 'DEMO')
    expect(logger.url).to eql(UsageLoggers.demo_url)
    json = String.new
    JsonMessage.start(json, 'echo', logger.agent, logger.version, Time.now.to_i)
    JsonMessage.stop(json)
    expect(logger.submit(json)).to be true
  end

  it 'submits to invalid url and fails' do
    URLS_UNRESOLVABLE.each do |url|
      logger = HttpLogger.new(url: url)
      expect(logger.submit('TEST-ABC')).to be false
    end
  end

  it 'submits to queue' do
    queue = []
    logger = HttpLogger.new(queue: queue, url: URLS_UNRESOLVABLE[0])
    expect(logger.url).to be nil
    expect(logger.enabled?).to be true
    expect(queue.length).to be 0
    expect(logger.submit('TEST-123')).to be true
    expect(queue.length).to eql(1)
    expect(logger.submit('TEST-234')).to be true
    expect(queue.length).to eql(2)
  end

  it 'uses version' do
    version = HttpLogger.version_lookup
    expect(version).to be_kind_of String
    expect(version).not_to be nil
    expect(version.length).to be > 0
    expect(version.start_with?('1.5.')).to be true
    expect(version.include?('\\')).to be false
    expect(version.include?('\"')).to be false
    expect(version.include?('\'')).to be false
    expect(HttpLogger.new.version).to eql(HttpLogger.version_lookup)
  end

end
