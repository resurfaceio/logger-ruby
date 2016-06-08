# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'json'
require 'rack'
require 'resurfaceio/all'

MOCK_COOKIE = 'jsonrpc.session=3iqp3ydRwFyqjcfO0GT2bzUh.bacc2786c7a81df0d0e950bec8fa1a9b1ba0bb61'

MOCK_USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:26.0) Gecko/20100101 Firefox/26.0'

MOCK_ENV = {
    'HTTP_HOST' => 'localhost:3000',
    'HTTP_USER_AGENT' => MOCK_USER_AGENT,
    'HTTP_COOKIE' => MOCK_COOKIE,
    'PATH_INFO' => '/index.html',
    'QUERY_STRING' => 'foo=bar',
    'REQUEST_METHOD' => 'GET',
    'rack.url_scheme' => 'http',
}

MOCK_HEADERS_ESCAPED = "{\"host\":\"localhost:3000\"},{\"user-agent\":\"#{MOCK_USER_AGENT}\"},{\"cookie\":\"#{MOCK_COOKIE}\"}"

MOCK_JSON = "{ \"hello\" : \"world\" }"

MOCK_JSON_ENV = MOCK_ENV.clone.merge ({
    'CONTENT_TYPE' => 'application/json', 'rack.input' => StringIO.new(MOCK_JSON), 'REQUEST_METHOD' => 'POST'
})

MOCK_JSON_ENV_ESCAPED = "#{MOCK_HEADERS_ESCAPED},{\"content-type\":\"application/json\"}"

MOCK_JSON_ESCAPED = JsonMessage.escape('', MOCK_JSON)

MOCK_JSON_ALT = "{ \"moonbeam\" : \"city\" }"

MOCK_JSON_ALT_ESCAPED = JsonMessage.escape('', MOCK_JSON_ALT)

MOCK_HTML = '<html>Hello World!</html>'

MOCK_HTML_ESCAPED = JsonMessage.escape('', MOCK_HTML)

MOCK_HTML_ALT = '<html><h1>We want the funk</h1><p>Gotta have that funk</p></html>'

MOCK_HTML_ALT_ESCAPED = JsonMessage.escape('', MOCK_HTML_ALT)

MOCK_INVALID_URLS = ["#{HttpLogger::DEFAULT_URL}/noway3is5this1valid2", 'https://www.noway3is5this1valid2.com/',
                     'http://www.noway3is5this1valid2.com/']

MOCK_URL = 'http://localhost:3000/index.html?foo=bar'

class MockCustomApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/super-troopers'
    [200, headers, ['do you know how fast you were going?']]
  end
end

class MockCustomRedirectApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/crazy'
    [304, headers, ['']]
  end
end

class MockJsonApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/json'
    [200, headers, [MOCK_JSON]]
  end
end

class MockJsonRedirectApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/json'
    [304, headers, ['']]
  end
end

class MockHtmlApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'text/html'
    headers['A'] = '1'
    [200, headers, [MOCK_HTML]]
  end
end

class MockHtmlRedirectApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'text/html; charset=utf-8'
    [304, headers, [MOCK_HTML]]
  end
end

class MockRailsHtmlController
  def request
    mock_request
  end

  def response
    mock_response_with_body
  end
end

class MockRailsJsonController < MockRailsHtmlController
  def request
    mock_request_with_body
  end
end

def mock_request
  r = HttpRequestImpl.new
  r.request_method = 'GET'
  r.url = MOCK_URL
  r
end

def mock_request_with_body
  r = HttpRequestImpl.new
  r.content_type = 'application/json'
  r.request_method = 'POST'
  r.raw_body = MOCK_JSON
  r.url = MOCK_URL
  r
end

def mock_request_with_body2
  r = HttpRequestImpl.new
  r.content_type = 'application/json'
  r.headers['HTTP_ABC'] = '123'
  r.request_method = 'POST'
  r.raw_body = MOCK_JSON
  r.url = MOCK_URL
  r
end

def mock_response
  r = HttpResponseImpl.new
  r.status = 200
  r
end

def mock_response_with_body
  r = HttpResponseImpl.new
  r.raw_body = MOCK_HTML
  r.status = 200
  r
end

def parseable?(json)
  return false if json.nil? || !json.chars.first == '{' || !json.chars.last == '}'
  begin
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end
end
