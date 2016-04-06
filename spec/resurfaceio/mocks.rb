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

MOCK_ENV_URL = 'http://localhost:3000/index.html'

MOCK_JSON = "{ \"hello\" : \"world\" }"

MOCK_JSON_ESCAPED = JsonMessage.escape('', MOCK_JSON)

MOCK_HTML = '<html>Hello World!</html>'

MOCK_HTML_ESCAPED = JsonMessage.escape('', MOCK_HTML)

MOCK_HTML_ALT = '<html><h1>We want the funk</h1><p>Gotta have that funk</p></html>'

MOCK_HTML_ALT_ESCAPED = JsonMessage.escape('', MOCK_HTML_ALT)

class MockController
  def request
    MockRequest.new
  end

  def response
    MockResponseWithBody.new
  end
end

class MockCustomApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/super-troopers'
    [200, headers, 'do you know how fast you were going?']
  end
end

class MockCustomRedirectingApp
  def call(env)
    [304, {}, '']
  end
end

class MockHtmlApp
  def call(env)
    headers = {}
    headers[Rack::CACHE_CONTROL] = 'private, max-age=0, no-cache'
    headers[Rack::CONTENT_TYPE] = 'text/html'
    [200, headers, MOCK_HTML]
  end
end

class MockHtmlRedirectingApp
  def call(env)
    headers = {}
    headers[Rack::CACHE_CONTROL] = 'private, max-age=0, no-cache'
    headers[Rack::CONTENT_TYPE] = 'text/html'
    [304, headers, MOCK_HTML]
  end
end

class MockJsonApp
  def call(env)
    headers = {}
    headers[Rack::CACHE_CONTROL] = 'private, max-age=0, no-cache'
    headers[Rack::CONTENT_TYPE] = 'application/json; charset=utf-8'
    [200, headers, MOCK_JSON]
  end
end

class MockRequest
  def url
    MOCK_ENV_URL
  end
end

class MockResponse
  def body
    nil
  end

  def status
    200
  end
end

class MockResponseWithBody
  def body
    MOCK_HTML
  end

  def status
    200
  end
end

def verify_mock_request(message)
  expect(message.include?("{\"category\":\"http_request\",")).to be true
  expect(message.include?("\"source\":\"#{HttpLogger::SOURCE}\",")).to be true
  expect(message.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
  expect(message.include?("\"now\"")).to be true
  expect(message.include?("\"url\":\"#{MOCK_ENV_URL}\"}")).to be true
end

def verify_mock_response(message, body=nil)
  expect(message.include?("{\"category\":\"http_response\",")).to be true
  expect(message.include?("\"source\":\"#{HttpLogger::SOURCE}\",")).to be true
  expect(message.include?("\"version\":\"#{HttpLogger.version_lookup}\",")).to be true
  expect(message.include?("\"now\"")).to be true
  expect(message.include?("\"code\":200",)).to be true
  unless body.nil?
    expect(message.include?("\"body\":\"#{body}\"}")).to be true
  end
end
