# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'rack'

MOCK_ENV = {
    'GATEWAY_INTERFACE' => 'CGI/1.1',
    'PATH_INFO' => '/index.html',
    'QUERY_STRING' => '',
    'REMOTE_ADDR' => '::1',
    'REMOTE_HOST' => 'localhost',
    'REQUEST_METHOD' => 'GET',
    'REQUEST_URI' => 'http://localhost:3000/index.html',
    'SCRIPT_NAME' => '',
    'SERVER_NAME' => 'localhost',
    'SERVER_PORT' => '3000',
    'SERVER_PROTOCOL' => 'HTTP/1.1',
    'SERVER_SOFTWARE' => 'WEBrick/1.3.1 (Ruby/2.0.0/2013-11-22)',
    'HTTP_HOST' => 'localhost:3000',
    'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:26.0) Gecko/20100101 Firefox/26.0',
    'HTTP_ACCEPT' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'HTTP_ACCEPT_LANGUAGE' => 'zh-tw,zh;q=0.8,en-us;q=0.5,en;q=0.3',
    'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
    'HTTP_COOKIE' => 'jsonrpc.session=3iqp3ydRwFyqjcfO0GT2bzUh.bacc2786c7a81df0d0e950bec8fa1a9b1ba0bb61',
    'HTTP_CONNECTION' => 'keep-alive',
    'HTTP_CACHE_CONTROL' => 'max-age=0',
    'rack.version' => [1, 2],
    'rack.multiprocess' => false,
    'rack.run_once' => false,
    'rack.url_scheme' => 'http',
    'HTTP_VERSION' => 'HTTP/1.1',
    'REQUEST_PATH' => '/index.html'
}

MOCK_JSON = "{ \"hello\" : \"world\" }"

MOCK_JSON_ENV = MOCK_ENV.clone.merge ({
    'CONTENT_TYPE' => 'application/json', 'rack.input' => StringIO.new(MOCK_JSON), 'REQUEST_METHOD' => 'POST'
})

MOCK_JSON_ESCAPED = JsonMessage.escape('', MOCK_JSON)

MOCK_JSON_ALT = "{ \"moonbeam\" : \"city\" }"

MOCK_JSON_ALT_ESCAPED = JsonMessage.escape('', MOCK_JSON_ALT)

MOCK_HTML = '<html>Hello World!</html>'

MOCK_HTML_ESCAPED = JsonMessage.escape('', MOCK_HTML)

MOCK_HTML_ALT = '<html><h1>We want the funk</h1><p>Gotta have that funk</p></html>'

MOCK_HTML_ALT_ESCAPED = JsonMessage.escape('', MOCK_HTML_ALT)

MOCK_INVALID_URLS = ["#{HttpLogger::DEFAULT_URL}/noway3is5this1valid2", 'https://www.noway3is5this1valid2.com/',
                     'http://www.noway3is5this1valid2.com/']

MOCK_URL = 'http://localhost:3000/index.html'

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
    headers[Rack::CONTENT_TYPE] = 'application/json; charset=utf-8'
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
    headers[Rack::CACHE_CONTROL] = 'private, max-age=0, no-cache'
    headers[Rack::CONTENT_TYPE] = 'text/html'
    [200, headers, [MOCK_HTML]]
  end
end

class MockHtmlRedirectApp
  def call(env)
    headers = {}
    headers[Rack::CACHE_CONTROL] = 'private, max-age=0, no-cache'
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
