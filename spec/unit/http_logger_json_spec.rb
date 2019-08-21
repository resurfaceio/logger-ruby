# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

require 'resurfaceio/all'
require_relative 'helper'

logger = HttpLogger.new(rules: 'include standard')

describe HttpLogger do

  it 'formats request' do
    json = logger.format(mock_request, mock_response, nil, nil, MOCK_NOW)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"agent\",\"#{HttpLogger::AGENT}\"]")).to be true
    expect(json.include?("[\"version\",\"#{HttpLogger.version_lookup}\"]")).to be true
    expect(json.include?("[\"now\",\"#{MOCK_NOW}\"]")).to be true
    expect(json.include?("[\"request_method\",\"GET\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}\"]")).to be true
    expect(json.include?('request_body')).to be false
    expect(json.include?('request_header')).to be false
    expect(json.include?('request_param')).to be false
  end

  it 'formats request with body' do
    json = logger.format(mock_request_with_json, mock_response, nil, MOCK_HTML)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"request_body\",\"#{MOCK_HTML}\"]")).to be true
    expect(json.include?("[\"request_header:content-type\",\"Application/JSON\"]")).to be true
    expect(json.include?("[\"request_method\",\"POST\"]")).to be true
    expect(json.include?("[\"request_param:message\",\"#{MOCK_JSON_ESCAPED}\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}?#{MOCK_QUERY_STRING}\"]")).to be true
    expect(json.include?('request_param:foo')).to be false
  end

  it 'formats request with empty body' do
    json = logger.format(mock_request_with_json2, mock_response, nil, '')
    expect(parseable?(json)).to be true
    expect(json.include?("[\"request_header:a\",\"1, 2\"]")).to be true
    expect(json.include?("[\"request_header:abc\",\"123\"]")).to be true
    expect(json.include?("[\"request_header:content-type\",\"Application/JSON\"]")).to be true
    expect(json.include?("[\"request_method\",\"POST\"]")).to be true
    expect(json.include?("[\"request_param:abc\",\"123\"]")).to be true
    expect(json.include?("[\"request_param:abc\",\"234\"]")).to be true
    expect(json.include?("[\"request_param:message\",\"#{MOCK_JSON_ESCAPED}\"]")).to be true
    expect(json.include?("[\"request_url\",\"#{MOCK_URL}?#{MOCK_QUERY_STRING}\"]")).to be true
    expect(json.include?('request_body')).to be false
    expect(json.include?('request_param:foo')).to be false
  end

  it 'formats request with missing details' do
    json = logger.format(HttpRequestImpl.new, mock_response)
    expect(parseable?(json)).to be true
    expect(json.include?('request_body')).to be false
    expect(json.include?('request_header')).to be false
    expect(json.include?('request_method')).to be false
    expect(json.include?('request_param')).to be false
    expect(json.include?('request_url')).to be false
  end

  it 'formats response' do
    json = logger.format(mock_request, mock_response)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?('response_body')).to be false
    expect(json.include?('response_header')).to be false
  end

  it 'formats response with body' do
    json = logger.format(mock_request, mock_response_with_html, MOCK_HTML2)
    expect(parseable?(json)).to be true
    expect(json.include?("[\"response_body\",\"#{MOCK_HTML2}\"]")).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?("[\"response_header:content-type\",\"text/html; charset=utf-8\"]")).to be true
  end

  it 'formats response with empty body' do
    json = logger.format(mock_request, mock_response_with_html, '')
    expect(parseable?(json)).to be true
    expect(json.include?("[\"response_code\",\"200\"]")).to be true
    expect(json.include?("[\"response_header:content-type\",\"text/html; charset=utf-8\"]")).to be true
    expect(json.include?('response_body')).to be false
  end

  it 'formats response with missing details' do
    # this is the default behavior with Sinatra, https://github.com/resurfaceio/logger-ruby/issues/18
    response = HttpResponseImpl.new
    response.content_type = nil
    json = logger.format(mock_request, response)
    expect(parseable?(json)).to be true
    expect(json.include?('response_body')).to be false
    expect(json.include?('response_code')).to be false
    expect(json.include?('response_header')).to be false
  end

end
