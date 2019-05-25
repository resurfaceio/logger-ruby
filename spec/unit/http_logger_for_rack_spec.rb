# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLoggerForRack do

  it 'logs html' do
    queue = []
    HttpLoggerForRack.new(MockHtmlApp.new, queue: queue, rules: 'include standard').call(MOCK_ENV)
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("[\"request_header:cookie\",")).to be false
    expect(json.include?("[\"request_header:host\",\"localhost:3000\"]")).to be true
    expect(json.include?("[\"request_header:user-agent\",\"#{MOCK_USER_AGENT}\"]")).to be true
    expect(json.include?("[\"request_method\",\"GET\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}?#{MOCK_QUERY_STRING}\"]")).to be true
    expect(json.include?("[\"response_body\",\"#{MOCK_HTML}\"]")).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?("[\"response_header:a\",\"1\"]")).to be true
    expect(json.include?("[\"response_header:content-length\",\"25\"]")).to be true
    expect(json.include?("[\"response_header:content-type\",\"text/html; charset=utf-8\"]")).to be true
    expect(json.include?('request_body')).to be false
    expect(json.include?('request_param')).to be false
  end

  it 'logs json' do
    queue = []
    HttpLoggerForRack.new(MockJsonApp.new, queue: queue, rules: 'include standard').call(MOCK_ENV)
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("[\"request_header:cookie\",")).to be false
    expect(json.include?("[\"request_header:host\",\"localhost:3000\"]")).to be true
    expect(json.include?("[\"request_header:user-agent\",\"#{MOCK_USER_AGENT}\"]")).to be true
    expect(json.include?("[\"request_method\",\"GET\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}?#{MOCK_QUERY_STRING}\"]")).to be true
    expect(json.include?("[\"response_body\",\"#{MOCK_JSON_ESCAPED}\"]")).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?("[\"response_header:content-length\",\"21\"]")).to be true
    expect(json.include?("[\"response_header:content-type\",\"application/json\"]")).to be true
    expect(json.include?('request_body')).to be false
    expect(json.include?('request_param')).to be false
  end

  it 'logs json post' do
    queue = []
    HttpLoggerForRack.new(MockJsonApp.new, queue: queue, rules: 'include standard').call(MOCK_ENV_JSON)
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("[\"request_header:content-type\",\"application/json\"]")).to be true
    expect(json.include?("[\"request_header:cookie\",")).to be false
    expect(json.include?("[\"request_header:host\",\"localhost:3000\"]")).to be true
    expect(json.include?("[\"request_header:user-agent\",\"#{MOCK_USER_AGENT}\"]")).to be true
    expect(json.include?("[\"request_method\",\"POST\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}?#{MOCK_QUERY_STRING}\"]")).to be true
    expect(json.include?("[\"response_body\",\"#{MOCK_JSON_ESCAPED}\"]")).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?("[\"response_header:content-length\",\"21\"]")).to be true
    expect(json.include?("[\"response_header:content-type\",\"application/json\"]")).to be true
    expect(json.include?('request_body')).to be false
    expect(json.include?('request_param')).to be false
  end

  it 'skips logging for exceptions' do
    queue = []
    begin
      HttpLoggerForRack.new(MockExceptionApp.new, queue: queue).call(MOCK_ENV)
    rescue ZeroDivisionError
      expect(queue.length).to eql(0)
    end
  end

  it 'skips logging for 404s and unmatched content types' do
    apps = [MockCustomApp.new, MockCustom404App.new, MockHtml404App.new, MockJson404App.new]
    apps.each do |app|
      queue = []
      HttpLoggerForRack.new(app, queue: queue).call(MOCK_ENV)
      expect(queue.length).to eql(0)
    end
  end

end
