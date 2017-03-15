# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLogger do

  it 'uses module namespace' do
    expect(HttpLogger.class.equal?(Resurfaceio::HttpLogger.class)).to be true
    expect(Resurfaceio::HttpLogger.version_lookup).to eql(HttpLogger.version_lookup)
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

  it 'formats request with nil method and url' do
    json = HttpLogger.new.format(HttpRequestImpl.new, nil, mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("\"request_body\"")).to be false
    expect(json.include?("\"request_method\"")).to be false
    expect(json.include?("\"request_url\"")).to be false
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

  it 'formats response with nil content type and response code' do
    # this is the default behavior with Sinatra, https://github.com/resurfaceio/resurfaceio-logger-ruby/issues/18
    response = HttpResponseImpl.new
    response.content_type = nil
    json = HttpLogger.new.format(mock_request, nil, response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("\"request_body\"")).to be false
    expect(json.include?("\"response_body\"")).to be false
    expect(json.include?("\"response_code\"")).to be false
    expect(json.include?("\"response_headers\":[]")).to be true
  end

  it 'manages multiple instances' do
    url1 = 'http://resurface.io'
    url2 = 'http://whatever.com'
    logger1 = HttpLogger.new(url: url1)
    logger2 = HttpLogger.new(url: url2)
    logger3 = HttpLogger.new(url: 'DEMO')

    expect(logger1.agent).to eql(HttpLogger::AGENT)
    expect(logger1.enabled?).to be true
    expect(logger1.url).to eql(url1)
    expect(logger2.agent).to eql(HttpLogger::AGENT)
    expect(logger2.enabled?).to be true
    expect(logger2.url).to eql(url2)
    expect(logger3.agent).to eql(HttpLogger::AGENT)
    expect(logger3.enabled?).to be true
    expect(logger3.url).to eql(UsageLoggers.url_for_demo)

    UsageLoggers.disable
    expect(UsageLoggers.enabled?).to be false
    expect(logger1.enabled?).to be false
    expect(logger2.enabled?).to be false
    expect(logger3.enabled?).to be false
    UsageLoggers.enable
    expect(UsageLoggers.enabled?).to be true
    expect(logger1.enabled?).to be true
    expect(logger2.enabled?).to be true
    expect(logger3.enabled?).to be true
  end

  it 'provides valid agent' do
    agent = HttpLogger::AGENT
    expect(agent).not_to be nil
    expect(agent).to be_kind_of String
    expect(agent.length).to be > 0
    expect(agent.end_with?('.rb')).to be true
    expect(agent.include?('\\')).to be false
    expect(agent.include?('\"')).to be false
    expect(agent.include?('\'')).to be false
    expect(HttpLogger.new.agent).to eql(agent)
  end

  it 'skips logging when disabled' do
    URLS_DENIED.each do |url|
      logger = HttpLogger.new(url: url).disable
      expect(logger.enabled?).to be false
      expect(logger.log(nil, nil, nil, nil)).to be true # would fail if enabled
    end
  end

end
