# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'
require_relative 'mocks'

describe HttpLogger do

  it 'uses module namespace' do
    expect(HttpLogger.class.equal?(Resurfaceio::HttpLogger.class)).to be true
    expect(Resurfaceio::HttpLogger.version_lookup).to eql(HttpLogger.version_lookup)
  end

  it 'formats echo' do
    message = HttpLogger.new.format_echo(String.new, 1234)
    expect(message).to be_kind_of String
    expect(message).not_to be nil
    expect(message.length).to be > 0
    expect(message.include?("{\"category\":\"echo\",")).to be true
    expect(message.include?("\"source\":\"#{HttpLogger::SOURCE}\",")).to be true
    expect(message.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(message.include?("\"now\":1234}")).to be true
  end

  it 'formats request' do
    message = HttpLogger.new.format_request(String.new, 1455908640173, MockRequest.new)
    expect(message.include?("{\"category\":\"http_request\",")).to be true
    expect(message.include?("\"source\":\"#{HttpLogger::SOURCE}\",")).to be true
    expect(message.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(message.include?("\"now\":1455908640173,")).to be true
    expect(message.include?("\"url\":\"http://something.com/index.html\"}")).to be true
  end

  it 'formats response' do
    message = HttpLogger.new.format_response(String.new, 1455908665227, MockResponse.new)
    expect(message.include?("{\"category\":\"http_response\",")).to be true
    expect(message.include?("\"source\":\"#{HttpLogger::SOURCE}\",")).to be true
    expect(message.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(message.include?("\"now\":1455908665227,")).to be true
    expect(message.include?("\"code\":404}")).to be true
  end

  it 'formats response with body' do
    message = HttpLogger.new.format_response(String.new, 1455908665887, MockResponseWithBody.new)
    expect(message.include?("{\"category\":\"http_response\",")).to be true
    expect(message.include?("\"source\":\"#{HttpLogger::SOURCE}\",")).to be true
    expect(message.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
    expect(message.include?("\"now\":1455908665887,")).to be true
    expect(message.include?("\"code\":200",)).to be true
    expect(message.include?("\"body\":\"#{MockResponseWithBody::BODY}\"}")).to be true
  end

  it 'logs echo (to default url)' do
    logger = HttpLogger.new
    expect(logger.log_echo).to be true
    expect(logger.tracing_history.length).to be 0
  end

  it 'logs echo (to invalid url)' do
    logger = HttpLogger.new("#{HttpLogger::URL}/noway3is5this1valid2")
    expect(logger.log_echo).to be false
    expect(logger.tracing_history.length).to be 0

    logger = HttpLogger.new('https://www.noway3is5this1valid2.com/')
    expect(logger.log_echo).to be false
    expect(logger.tracing_history.length).to be 0

    logger = HttpLogger.new('http://www.noway3is5this1valid2.com/')
    expect(logger.log_echo).to be false
    expect(logger.tracing_history.length).to be 0
  end

  it 'skips logging and tracing when disabled' do
    logger = HttpLogger.new("#{HttpLogger::URL}/noway3is5this1valid2", false)
    expect(logger.log_echo).to be true
    expect(logger.tracing_history.length).to be 0

    logger = HttpLogger.new('https://www.noway3is5this1valid2.com/', false)
    expect(logger.log_echo).to be true
    expect(logger.tracing_history.length).to be 0

    logger = HttpLogger.new('http://www.noway3is5this1valid2.com/', false)
    expect(logger.log_echo).to be true
    expect(logger.tracing_history.length).to be 0
  end

  it 'uses source' do
    source = HttpLogger::SOURCE
    expect(source).to be_kind_of String
    expect(source).not_to be nil
    expect(source.length).to be > 0
    expect(source.start_with?('resurfaceio-')).to be true
    expect(source.include?('\\')).to be false
    expect(source.include?('\"')).to be false
    expect(source.include?('\'')).to be false
  end

  it 'uses tracing' do
    logger = HttpLogger.new.disable
    expect(logger.enabled?).to be false
    expect(logger.tracing?).to be false
    expect(logger.tracing_history.length).to be 0
    logger.tracing_start
    begin
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
      expect(logger.enabled?).to be true
      expect(logger.tracing?).to be false
      expect(logger.tracing_history.length).to be 0
    end
  end

  it 'uses url' do
    url = HttpLogger::URL
    expect(url).to be_kind_of String
    expect(url).not_to be nil
    expect(url.length).to be > 0
    expect(url.start_with?('https://')).to be true
    expect(url.include?('\\')).to be false
    expect(url.include?('\"')).to be false
    expect(url.include?('\'')).to be false
    expect(HttpLogger.new.url).to eql(HttpLogger::URL)
    expect(HttpLogger.new('https://foobar.com').url).to eql('https://foobar.com')
  end

  it 'uses version' do
    version = HttpLogger.version_lookup
    expect(version).to be_kind_of String
    expect(version).not_to be nil
    expect(version.length).to be > 0
    expect(version.start_with?('1.0')).to be true
    expect(version.include?('\\')).to be false
    expect(version.include?('\"')).to be false
    expect(version.include?('\'')).to be false
    expect(HttpLogger.new.version).to eql(HttpLogger.version_lookup)
  end

end
