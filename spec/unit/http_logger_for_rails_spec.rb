# coding: utf-8
# © 2016-2020 Resurface Labs Inc.

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLoggerForRails do

  it 'logs html response' do
    queue = []
    HttpLoggerForRails.new(queue: queue, rules: 'include standard').around(MockRailsHtmlController.new) {}
    expect(queue.length).to eql(2)
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"request_method\",\"GET\"]")).to be true
    expect(msg.include?("[\"request_url\",\"#{MOCK_URL}\"]")).to be true
    expect(msg.include?("[\"response_body\",\"#{MOCK_HTML}\"]")).to be true
    expect(msg.include?("[\"response_code\",\"200\"]")).to be true
    expect(msg.include?("[\"response_header:content-type\",\"text/html; charset=utf-8\"]")).to be true
    expect(msg.include?("[\"interval\",")).to be true
    expect(msg.include?('request_body')).to be false
    expect(msg.include?('request_header')).to be false
    expect(msg.include?('request_param')).to be false
  end

  it 'logs html response to json request' do
    queue = []
    HttpLoggerForRails.new(queue: queue, rules: 'include standard').around(MockRailsJsonController.new) {}
    expect(queue.length).to eql(2)
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"request_header:content-type\",\"Application/JSON\"]")).to be true
    expect(msg.include?("[\"request_method\",\"POST\"]")).to be true
    expect(msg.include?("[\"request_param:message\",\"#{MOCK_JSON_ESCAPED}\"]")).to be true
    expect(msg.include?("[\"request_url\",\"#{MOCK_URL}?#{MOCK_QUERY_STRING}\"]")).to be true
    expect(msg.include?("[\"response_body\",\"#{MOCK_HTML}\"]")).to be true
    expect(msg.include?("[\"response_code\",\"200\"]")).to be true
    expect(msg.include?("[\"response_header:content-type\",\"text/html; charset=utf-8\"]")).to be true
    expect(msg.include?("[\"interval\",")).to be true
    expect(msg.include?('request_body')).to be false
  end

  it 'skips logging for exceptions' do
    queue = []
    begin
      HttpLoggerForRails.new(queue: queue).around(MockRailsHtmlController.new) {raise ZeroDivisionError}
    rescue ZeroDivisionError
      expect(queue.length).to eql(1)
    end
  end

end
