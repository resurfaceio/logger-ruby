# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLoggerForRails do

  it 'uses module namespace' do
    expect(HttpLoggerForRails.class.equal?(Resurfaceio::HttpLoggerForRails.class)).to be true
  end

  it 'logs html response' do
    queue = []
    HttpLoggerForRails.new(queue: queue).around(MockRailsHtmlController.new) {}
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"request_body\"")).to be false
    expect(json.include?("\"request_headers\":[]")).to be true
    expect(json.include?("\"request_method\":\"GET\"")).to be true
    expect(json.include?("\"request_url\":\"#{MOCK_URL}\"")).to be true
    expect(json.include?("\"response_body\":\"#{MOCK_HTML_ESCAPED}\"")).to be true
    expect(json.include?("\"response_code\":\"200\"")).to be true
    expect(json.include?("\"response_headers\":[]")).to be true
  end

  it 'logs html response to json request' do
    queue = []
    HttpLoggerForRails.new(queue: queue).around(MockRailsJsonController.new) {}
    expect(queue.length).to eql(1)
    json = queue[0]
    expect(parseable?(json)).to be true
    expect(json.include?("\"category\":\"http\"")).to be true
    expect(json.include?("\"request_body\":\"#{MOCK_JSON_ESCAPED}\"")).to be true
    expect(json.include?("\"request_headers\":[{\"content-type\":\"application/json\"}]")).to be true
    expect(json.include?("\"request_method\":\"POST\"")).to be true
    expect(json.include?("\"request_url\":\"#{MOCK_URL}\"")).to be true
    expect(json.include?("\"response_body\":\"#{MOCK_HTML_ESCAPED}\"")).to be true
    expect(json.include?("\"response_code\":\"200\"")).to be true
    expect(json.include?("\"response_headers\":[]")).to be true
  end

end
