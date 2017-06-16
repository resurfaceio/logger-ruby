# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'json'
require 'rack'
require 'resurfaceio/all'

DEMO_URL = 'https://demo-resurfaceio.herokuapp.com/ping'

MOCK_AGENT = 'helper.rb'

MOCK_COOKIE = 'jsonrpc.session=3iqp3ydRwFyqjcfO0GT2bzUh.bacc2786c7a81df0d0e950bec8fa1a9b1ba0bb61'

MOCK_JSON = "{ \"hello\" : \"world\" }"

MOCK_JSON_ESCAPED = "{ \\\"hello\\\" : \\\"world\\\" }"

MOCK_HTML = '<html>Hello World!</html>'

MOCK_NOW = '1455908640173'

MOCK_QUERY_STRING = 'foo=bar'

MOCK_URL = 'http://localhost:3000/index.html'

MOCK_URLS_DENIED = ["#{DEMO_URL}/noway3is5this1valid2", 'https://www.noway3is5this1valid2.com/']

MOCK_URLS_INVALID = ['', 'noway3is5this1valid2', 'ftp:\\www.noway3is5this1valid2.com/', 'urn:ISSN:1535–3613']

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

MOCK_ENV_JSON = MOCK_ENV.clone.merge ({
    'CONTENT_TYPE' => 'application/json', 'rack.input' => StringIO.new(MOCK_JSON), 'REQUEST_METHOD' => 'POST'
})

class MockCustomApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/super-troopers'
    [200, headers, ['do you know how fast you were going?']]
  end
end

class MockCustomApp2
  def call(env)
    headers = {}
    headers['content_type'] = 'text/html'
    [200, headers, ['license and registration, please']]
  end
end

class MockCustomRedirectApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/crazy'
    [304, headers, ['']]
  end
end

class MockExceptionApp
  def call(env)
    raise ZeroDivisionError
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
    headers[Rack::CONTENT_TYPE] = 'text/html; charset=utf-8'
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
  r.content_type = 'Application/JSON'
  r.request_method = 'POST'
  r.raw_body = MOCK_JSON
  r.url = "#{MOCK_URL}?#{MOCK_QUERY_STRING}"
  r
end

def mock_request_with_body2
  r = mock_request_with_body
  r.headers['HTTP_ABC'] = '123'
  r.add_header 'HTTP_A', '1'
  r.add_header 'HTTP_A', '2'
  r
end

def mock_response
  r = HttpResponseImpl.new
  r.status = 200
  r
end

def mock_response_with_body
  r = HttpResponseImpl.new
  r.content_type = 'text/html; charset=utf-8'
  r.raw_body = MOCK_HTML
  r.status = 200
  r
end

def parseable?(json)
  return false if json.nil? || json.chars.first != '[' || json.chars.last != ']'
  begin
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end
end
