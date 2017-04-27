# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLogger do

  it 'formats request with body' do
    json = HttpLogger.new.format(mock_request_with_body, nil, mock_response, nil, MOCK_NOW)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"agent\",\"#{HttpLogger::AGENT}\"]")).to be true
    expect(json.include?("[\"version\",\"#{HttpLogger.version_lookup}\"]")).to be true
    expect(json.include?("[\"now\",\"#{MOCK_NOW}\"]")).to be true
    expect(json.include?("[\"request_body\",\"#{MOCK_JSON_ESCAPED}\"]")).to be true
    expect(json.include?("[\"request_header.content-type\",\"application/json\"]")).to be true
    expect(json.include?("[\"request_method\",\"POST\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}\"]")).to be true
  end

  it 'formats request with empty body' do
    json = HttpLogger.new.format(mock_request_with_body2, '', mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"request_body\",\"\"]")).to be true
    expect(json.include?("[\"request_header.abc\",\"123\"]")).to be true
    expect(json.include?("[\"request_header.content-type\",\"application/json\"]")).to be true
    expect(json.include?("[\"request_method\",\"POST\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}\"]")).to be true
  end

  it 'formats request with alternative body' do
    json = HttpLogger.new.format(mock_request_with_body2, MOCK_JSON_ALT, mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"request_body\",\"#{MOCK_JSON_ALT_ESCAPED}\"]")).to be true
    expect(json.include?("[\"request_header.abc\",\"123\"]")).to be true
    expect(json.include?("[\"request_header.content-type\",\"application/json\"]")).to be true
    expect(json.include?("[\"request_method\",\"POST\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}\"]")).to be true
  end

  it 'formats request with nil method and url' do
    json = HttpLogger.new.format(HttpRequestImpl.new, nil, mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?('request_body')).to be false
    expect(json.include?('request_method')).to be false
    expect(json.include?('request_url')).to be false
  end

  it 'formats response' do
    json = HttpLogger.new.format(mock_request, nil, mock_response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?('response_body')).to be false
    expect(json.include?('response_header')).to be false
  end

  it 'formats response with body' do
    json = HttpLogger.new.format(mock_request, nil, mock_response_with_body, nil)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"response_body\",\"#{MOCK_HTML_ESCAPED}\"]")).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?('response_header')).to be false
  end

  it 'formats response with empty body' do
    json = HttpLogger.new.format(mock_request, nil, mock_response_with_body, '')
    expect(parseable?(json)).to be true
    expect(json.include?("[\"response_body\",\"\"]")).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?('response_header')).to be false
  end

  it 'formats response with alternate body' do
    json = HttpLogger.new.format(mock_request, nil, mock_response_with_body, MOCK_HTML_ALT)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"response_body\",\"#{MOCK_HTML_ALT_ESCAPED}\"]")).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?('response_header')).to be false
  end

  it 'formats response with nil content type and response code' do
    # this is the default behavior with Sinatra, https://github.com/resurfaceio/logger-ruby/issues/18
    response = HttpResponseImpl.new
    response.content_type = nil
    json = HttpLogger.new.format(mock_request, nil, response, nil)
    expect(parseable?(json)).to be true
    expect(json.include?('request_body')).to be false
    expect(json.include?('response_body')).to be false
    expect(json.include?('response_code')).to be false
    expect(json.include?('response_header')).to be false
  end

end
