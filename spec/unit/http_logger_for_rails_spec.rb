# coding: utf-8
# © 2016-2018 Resurface Labs LLC

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLoggerForRails do

  it 'logs html response' do
    queue = []
    HttpLoggerForRails.new(queue: queue).around(MockRailsHtmlController.new) {}
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("[\"request_method\",\"GET\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}\"]")).to be true
    expect(json.include?("[\"response_body\",\"#{MOCK_HTML}\"]")).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?("[\"response_header:content-type\",\"text/html; charset=utf-8\"]")).to be true
    expect(json.include?('request_body')).to be false
    expect(json.include?('request_header')).to be false
    expect(json.include?('request_param')).to be false
  end

  it 'logs html response to json request' do
    queue = []
    HttpLoggerForRails.new(queue: queue).around(MockRailsJsonController.new) {}
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("[\"request_header:content-type\",\"Application/JSON\"]")).to be true
    expect(json.include?("[\"request_method\",\"POST\"]")).to be true
    expect(json.include?("[\"request_param:message\",\"#{MOCK_JSON_ESCAPED}\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}?#{MOCK_QUERY_STRING}\"]")).to be true
    expect(json.include?("[\"response_body\",\"#{MOCK_HTML}\"]")).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?("[\"response_header:content-type\",\"text/html; charset=utf-8\"]")).to be true
    expect(json.include?('request_body')).to be false
  end

  it 'skips logging for exceptions' do
    queue = []
    begin
      HttpLoggerForRails.new(queue: queue).around(MockRailsHtmlController.new) {raise ZeroDivisionError}
    rescue ZeroDivisionError
      expect(queue.length).to eql(0)
    end
  end

end
