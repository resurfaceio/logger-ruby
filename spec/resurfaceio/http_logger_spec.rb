# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/loggers'

describe HttpLogger do

  class MockRequest
    def url
      'http://something.com/index.html'
    end
  end

  class MockResponse
    def status
      201
    end
  end

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
    expect(message.include?("\"code\":201}")).to be true
  end

  it 'logs echo' do
    expect(HttpLogger.new.log_echo).to be true
    expect(HttpLogger.new("#{HttpLogger::URL}/noway3is5this1valid2").log_echo).to be false
    expect(HttpLogger.new('https://www.noway3is5this1valid2.com/').log_echo).to be false
    expect(HttpLogger.new('http://www.noway3is5this1valid2.com/').log_echo).to be false
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
