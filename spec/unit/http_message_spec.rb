# coding: utf-8
# © 2016-2020 Resurface Labs Inc.

require 'resurfaceio/all'
require_relative 'helper'

describe HttpMessage do

  it 'formats metadata' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'include debug')
    HttpMessage.send(logger, mock_request, mock_response, nil, nil, MOCK_NOW)
    expect(queue.length).to be 2
    msg = queue[0]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"agent\",\"#{HttpLogger::AGENT}\"]")).to be true
    expect(msg.include?("[\"host\",\"#{HttpLogger.host_lookup}\"]")).to be true
    expect(msg.include?("[\"message_type\",\"metadata\"]")).to be true
    expect(msg.include?("[\"metadata_id\",\"#{logger.metadata_id}\"]")).to be true
    expect(msg.include?("[\"version\",\"#{HttpLogger.version_lookup}\"]")).to be true
    expect(msg.include?("[\"graphql_schema")).to be false
    expect(msg.include?("[\"interval")).to be false
    expect(msg.include?("[\"now")).to be false
    expect(msg.include?("[\"request_")).to be false
    expect(msg.include?("[\"response_")).to be false
  end

  it 'formats request' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'include debug')
    HttpMessage.send(logger, mock_request, mock_response, nil, nil, MOCK_NOW)
    expect(queue.length).to be 2
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"metadata_id\",\"#{logger.metadata_id}\"]")).to be true
    expect(msg.include?("[\"now\",\"#{MOCK_NOW}\"]")).to be true
    expect(msg.include?("[\"request_method\",\"GET\"]")).to be true
    expect(msg.include?("[\"request_url\",\"#{MOCK_URL}\"]")).to be true
    expect(msg.include?("[\"agent")).to be false
    expect(msg.include?("[\"host")).to be false
    expect(msg.include?("[\"interval")).to be false
    expect(msg.include?("[\"message_type")).to be false
    expect(msg.include?("[\"request_body")).to be false
    expect(msg.include?("[\"request_header")).to be false
    expect(msg.include?("[\"request_param")).to be false
    expect(msg.include?("[\"version")).to be false
  end

  it 'formats request with body' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'include debug')
    HttpMessage.send(logger, mock_request_with_json, mock_response, nil, MOCK_HTML)
    expect(queue.length).to be 2
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"request_body\",\"#{MOCK_HTML}\"]")).to be true
    expect(msg.include?("[\"request_header:content-type\",\"Application/JSON\"]")).to be true
    expect(msg.include?("[\"request_method\",\"POST\"]")).to be true
    expect(msg.include?("[\"request_param:message\",\"#{MOCK_JSON_ESCAPED}\"]")).to be true
    expect(msg.include?("[\"request_url\",\"#{MOCK_URL}?#{MOCK_QUERY_STRING}\"]")).to be true
    expect(msg.include?("[\"request_param:foo")).to be false
  end

  it 'formats request with empty body' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'include debug')
    HttpMessage.send(logger, mock_request_with_json2, mock_response, nil, '')
    expect(queue.length).to be 2
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"request_header:a\",\"1, 2\"]")).to be true
    expect(msg.include?("[\"request_header:abc\",\"123\"]")).to be true
    expect(msg.include?("[\"request_header:content-type\",\"Application/JSON\"]")).to be true
    expect(msg.include?("[\"request_method\",\"POST\"]")).to be true
    expect(msg.include?("[\"request_param:abc\",\"123\"]")).to be true
    expect(msg.include?("[\"request_param:abc\",\"234\"]")).to be true
    expect(msg.include?("[\"request_param:message\",\"#{MOCK_JSON_ESCAPED}\"]")).to be true
    expect(msg.include?("[\"request_url\",\"#{MOCK_URL}?#{MOCK_QUERY_STRING}\"]")).to be true
    expect(msg.include?("[\"request_body")).to be false
    expect(msg.include?("[\"request_param:foo")).to be false
  end

  it 'formats request with missing details' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'include debug')
    HttpMessage.send(logger, HttpRequestImpl.new, mock_response, nil, nil, nil, nil)
    expect(queue.length).to be 2
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"interval")).to be false
    expect(msg.include?("[\"request_body")).to be false
    expect(msg.include?("[\"request_header")).to be false
    expect(msg.include?("[\"request_method")).to be false
    expect(msg.include?("[\"request_param")).to be false
    expect(msg.include?("[\"request_url")).to be false
  end

  it 'formats response' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'include debug')
    HttpMessage.send(logger, mock_request, mock_response)
    expect(queue.length).to be 2
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"response_code\",\"200\"]")).to be true
    expect(msg.include?("[\"response_body")).to be false
    expect(msg.include?("[\"response_header")).to be false
  end

  it 'formats response with body' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'include debug')
    HttpMessage.send(logger, mock_request, mock_response_with_html, MOCK_HTML2)
    expect(queue.length).to be 2
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"response_body\",\"#{MOCK_HTML2}\"]")).to be true
    expect(msg.include?("[\"response_code\",\"200\"]")).to be true
    expect(msg.include?("[\"response_header:content-type\",\"text/html; charset=utf-8\"]")).to be true
  end

  it 'formats response with empty body' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'include debug')
    HttpMessage.send(logger, mock_request, mock_response_with_html, '')
    expect(queue.length).to be 2
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"response_code\",\"200\"]")).to be true
    expect(msg.include?("[\"response_header:content-type\",\"text/html; charset=utf-8\"]")).to be true
    expect(msg.include?("[\"response_body")).to be false
  end

  it 'formats response with missing details' do
    # this is the default behavior with Sinatra, https://github.com/resurfaceio/logger-ruby/issues/18
    response = HttpResponseImpl.new
    response.content_type = nil

    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'include debug')
    HttpMessage.send(logger, mock_request, response, nil, nil, nil, nil)
    expect(queue.length).to be 2
    msg = queue[1]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"interval")).to be false
    expect(msg.include?("[\"response_body")).to be false
    expect(msg.include?("[\"response_code")).to be false
    expect(msg.include?("[\"response_header")).to be false
  end

end
