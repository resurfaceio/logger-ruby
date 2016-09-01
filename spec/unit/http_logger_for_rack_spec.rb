# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLoggerForRack do

  it 'uses module namespace' do
    expect(HttpLoggerForRack.class.equal?(Resurfaceio::HttpLoggerForRack.class)).to be true
  end

  it 'logs html' do
    queue = []
    HttpLoggerForRack.new(MockHtmlApp.new, queue: queue).call(MOCK_ENV)
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"request_body\"")).to be false
    expect(json.include?("\"request_headers\":[#{MOCK_HEADERS_ESCAPED}]")).to be true
    expect(json.include?("\"request_method\":\"GET\"")).to be true
    expect(json.include?("\"request_url\":\"#{MOCK_URL}\"")).to be true
    expect(json.include?("\"response_body\":\"#{MOCK_HTML_ESCAPED}\"")).to be true
    expect(json.include?("\"response_code\":\"200\"")).to be true
    expect(json.include?("\"response_headers\":[{\"content-type\":\"text/html\"},{\"a\":\"1\"},{\"content-length\":\"25\"}]")).to be true
  end

  it 'logs json' do
    queue = []
    HttpLoggerForRack.new(MockJsonApp.new, queue: queue).call(MOCK_ENV)
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"request_body\"")).to be false
    expect(json.include?("\"request_headers\":[#{MOCK_HEADERS_ESCAPED}]")).to be true
    expect(json.include?("\"request_method\":\"GET\"")).to be true
    expect(json.include?("\"request_url\":\"#{MOCK_URL}\"")).to be true
    expect(json.include?("\"response_body\":\"#{MOCK_JSON_ESCAPED}\"")).to be true
    expect(json.include?("\"response_code\":\"200\"")).to be true
    expect(json.include?("\"response_headers\":[{\"content-type\":\"application/json\"},{\"content-length\":\"21\"}]")).to be true
  end

  it 'logs json post' do
    queue = []
    HttpLoggerForRack.new(MockJsonApp.new, queue: queue).call(MOCK_JSON_ENV)
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"request_body\":\"#{MOCK_JSON_ESCAPED}\"")).to be true
    expect(json.include?("\"request_headers\":[#{MOCK_JSON_ENV_ESCAPED}]")).to be true
    expect(json.include?("\"request_method\":\"POST\"")).to be true
    expect(json.include?("\"request_url\":\"#{MOCK_URL}\"")).to be true
    expect(json.include?("\"response_body\":\"#{MOCK_JSON_ESCAPED}\"")).to be true
    expect(json.include?("\"response_code\":\"200\"")).to be true
    expect(json.include?("\"response_headers\":[{\"content-type\":\"application/json\"},{\"content-length\":\"21\"}]")).to be true
  end

  it 'skips logging for exceptions' do
    queue = []
    begin
      HttpLoggerForRack.new(MockExceptionApp.new, queue: queue).call(MOCK_ENV)
    rescue ZeroDivisionError
      expect(queue.length).to eql(0)
    end
  end

  it 'skips logging for redirects and unmatched content types' do
    apps = [MockCustomApp.new, MockCustomRedirectApp.new, MockHtmlRedirectApp.new]
    apps.each do |app|
      queue = []
      HttpLoggerForRack.new(app, queue: queue).call(MOCK_ENV)
      expect(queue.length).to eql(0)
    end
  end

end
