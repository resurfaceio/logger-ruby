# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'
require_relative 'mocks'

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

  it 'formats echo' do
    s = HttpLogger.new.format_echo(String.new, 1234)
    expect(s).to be_kind_of String
    expect(s).not_to be nil
    expect(s.length).to be > 0
    expect(s.include?("{\"category\":\"echo\",")).to be true
    expect(s.include?("\"agent\":\"#{HttpLogger::AGENT}\",")).to be true
    expect(s.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(s.include?("\"now\":1234}")).to be true
  end

  it 'formats request' do
    s = HttpLogger.new.format_request(String.new, 1455908640173, mock_request)
    expect(s.include?("{\"category\":\"http_request\",")).to be true
    expect(s.include?("\"agent\":\"#{HttpLogger::AGENT}\",")).to be true
    expect(s.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(s.include?("\"now\":1455908640173,")).to be true
    expect(s.include?("\"url\":\"#{MOCK_URL}\"}")).to be true
    expect(s.include?("\"body\"")).to be false
  end

  it 'formats request with body' do
    s = HttpLogger.new.format_request(String.new, 1455908640174, mock_request_with_body)
    expect(s.include?("{\"category\":\"http_request\",")).to be true
    expect(s.include?("\"agent\":\"#{HttpLogger::AGENT}\",")).to be true
    expect(s.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(s.include?("\"now\":1455908640174,")).to be true
    expect(s.include?("\"url\":\"#{MOCK_URL}\",")).to be true
    expect(s.include?("\"body\":\"#{MOCK_JSON_ESCAPED}\"}")).to be true
  end

  it 'formats request with empty body' do
    s = HttpLogger.new.format_request(String.new, 1455908640174, mock_request_with_body, '')
    expect(s.include?("{\"category\":\"http_request\",")).to be true
    expect(s.include?("\"agent\":\"#{HttpLogger::AGENT}\",")).to be true
    expect(s.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(s.include?("\"now\":1455908640174,")).to be true
    expect(s.include?("\"url\":\"#{MOCK_URL}\",")).to be true
    expect(s.include?("\"body\":\"\"}")).to be true
  end

  it 'formats request with alternative body' do
    s = HttpLogger.new.format_request(String.new, 1455908640175, mock_request_with_body, MOCK_JSON_ALT)
    expect(s.include?("{\"category\":\"http_request\",")).to be true
    expect(s.include?("\"agent\":\"#{HttpLogger::AGENT}\",")).to be true
    expect(s.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(s.include?("\"now\":1455908640175,")).to be true
    expect(s.include?("\"url\":\"#{MOCK_URL}\",")).to be true
    expect(s.include?("\"body\":\"#{MOCK_JSON_ALT_ESCAPED}\"}")).to be true
  end

  it 'formats response' do
    s = HttpLogger.new.format_response(String.new, 1455908665227, mock_response)
    expect(s.include?("{\"category\":\"http_response\",")).to be true
    expect(s.include?("\"agent\":\"#{HttpLogger::AGENT}\",")).to be true
    expect(s.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(s.include?("\"now\":1455908665227,")).to be true
    expect(s.include?("\"code\":200",)).to be true
    expect(s.include?("\"body\"")).to be false
  end

  it 'formats response with body' do
    s = HttpLogger.new.format_response(String.new, 1455908665887, mock_response_with_body)
    expect(s.include?("{\"category\":\"http_response\",")).to be true
    expect(s.include?("\"agent\":\"#{HttpLogger::AGENT}\",")).to be true
    expect(s.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(s.include?("\"now\":1455908665887,")).to be true
    expect(s.include?("\"code\":200",)).to be true
    expect(s.include?("\"body\":\"#{MOCK_HTML_ESCAPED}\"}")).to be true
  end

  it 'formats response with empty body' do
    s = HttpLogger.new.format_response(String.new, 1455908665887, mock_response_with_body, '')
    expect(s.include?("{\"category\":\"http_response\",")).to be true
    expect(s.include?("\"agent\":\"#{HttpLogger::AGENT}\",")).to be true
    expect(s.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(s.include?("\"now\":1455908665887,")).to be true
    expect(s.include?("\"code\":200",)).to be true
    expect(s.include?("\"body\":\"\"}")).to be true
  end

  it 'formats response with alternate body' do
    s = HttpLogger.new.format_response(String.new, 1455908667777, mock_response_with_body, MOCK_HTML_ALT)
    expect(s.include?("{\"category\":\"http_response\",")).to be true
    expect(s.include?("\"agent\":\"#{HttpLogger::AGENT}\",")).to be true
    expect(s.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(s.include?("\"now\":1455908667777,")).to be true
    expect(s.include?("\"code\":200",)).to be true
    expect(s.include?("\"body\":\"#{MOCK_HTML_ALT_ESCAPED}\"}")).to be true
  end

  it 'logs echo (to default url)' do
    logger = HttpLogger.new
    expect(logger.log_echo).to be true
    expect(logger.tracing_history.length).to be 0
  end

  it 'logs echo (to invalid url)' do
    MOCK_INVALID_URLS.each do |url|
      logger = HttpLogger.new(url)
      expect(logger.log_echo).to be false
      expect(logger.tracing_history.length).to be 0
    end
  end

  it 'skips logging and tracing when disabled' do
    MOCK_INVALID_URLS.each do |url|
      logger = HttpLogger.new(url, false)
      expect(logger.log_echo).to be true
      expect(logger.log_request(nil)).to be true
      expect(logger.log_response(nil)).to be true
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
      expect(logger.log_echo).to be true
      expect(logger.tracing_history.length).to eql(1)
      expect(logger.log_echo).to be true
      expect(logger.tracing_history.length).to eql(2)
      expect(logger.log_echo).to be true
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
