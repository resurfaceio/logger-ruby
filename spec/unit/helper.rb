# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

require 'json'
require 'rack'
require 'resurfaceio/all'

DEMO_URL = 'https://demo.resurface.io/ping'.freeze

MOCK_AGENT = 'helper.rb'.freeze

MOCK_COOKIE = 'jsonrpc.session=3iqp3ydRwFyqjcfO0GT2bzUh.bacc2786c7a81df0d0e950bec8fa1a9b1ba0bb61'.freeze

MOCK_HTML = '<html>Hello World!</html>'.freeze

MOCK_HTML2 = '<html>Hola Mundo!</html>'.freeze

MOCK_HTML3 = '<html>1 World 2 World Red World Blue World!</html>'.freeze

MOCK_HTML4 = "<html>1 World\n2 World\nRed World \nBlue World!\n</html>".freeze

MOCK_HTML5 = %q(<html>
<input type="hidden">SECRET1</input>
<input class='foo' type="hidden">
SECRET2
</input>
</html>).freeze

MOCK_JSON = "{ \"hello\" : \"world\" }".freeze

MOCK_JSON_ESCAPED = "{ \\\"hello\\\" : \\\"world\\\" }".freeze

MOCK_NOW = '1455908640173'.freeze

MOCK_QUERY_STRING = 'foo=bar'.freeze

MOCK_URL = 'http://localhost:3000/index.html'.freeze

MOCK_URLS_DENIED = ["#{DEMO_URL}/noway3is5this1valid2", 'https://www.noway3is5this1valid2.com/'].freeze

MOCK_URLS_INVALID = ['', 'noway3is5this1valid2', 'ftp:\\www.noway3is5this1valid2.com/', 'urn:ISSN:1535–3613'].freeze

MOCK_USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:26.0) Gecko/20100101 Firefox/26.0'.freeze

MOCK_ENV = {
    'HTTP_HOST' => 'localhost:3000',
    'HTTP_USER_AGENT' => MOCK_USER_AGENT,
    'HTTP_COOKIE' => MOCK_COOKIE,
    'PATH_INFO' => '/index.html',
    'QUERY_STRING' => 'foo=bar',
    'REQUEST_METHOD' => 'GET',
    'rack.url_scheme' => 'http',
}.freeze

MOCK_ENV_JSON = MOCK_ENV.clone.merge ({
    'CONTENT_TYPE' => 'application/json', 'REQUEST_METHOD' => 'POST'
}).freeze

class MockCustomApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/super-troopers'
    [200, headers, ['do you know how fast you were going?']]
  end
end

class MockCustom404App
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/whatever'
    [404, headers, ['']]
  end
end

class MockExceptionApp
  def call(env)
    raise ZeroDivisionError
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

class MockHtml404App
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'text/html; charset=utf-8'
    [404, headers, [MOCK_HTML]]
  end
end

class MockJsonApp
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/json'
    [200, headers, [MOCK_JSON]]
  end
end

class MockJson404App
  def call(env)
    headers = {}
    headers[Rack::CONTENT_TYPE] = 'application/json'
    [404, headers, ['']]
  end
end

class MockRailsHtmlController
  def request
    mock_request
  end

  def response
    mock_response_with_html
  end
end

class MockRailsJsonController < MockRailsHtmlController
  def request
    mock_request_with_json
  end
end

def mock_request
  r = HttpRequestImpl.new
  r.request_method = 'GET'
  r.url = MOCK_URL
  r
end

def mock_request_with_json
  r = HttpRequestImpl.new
  r.content_type = 'Application/JSON'
  r.form_hash[:message] = MOCK_JSON
  r.request_method = 'POST'
  r.url = "#{MOCK_URL}?#{MOCK_QUERY_STRING}"
  r
end

def mock_request_with_json2
  r = mock_request_with_json
  r.headers['HTTP_ABC'] = '123'
  r.add_header 'HTTP_A', '1'
  r.add_header 'HTTP_A', '2'
  r.form_hash['ABC'] = '123'
  r.query_hash['ABC'] = '234'
  r
end

def mock_response
  r = HttpResponseImpl.new
  r.status = 200
  r
end

def mock_response_with_html
  r = mock_response
  r.content_type = 'text/html; charset=utf-8'
  r.raw_body = MOCK_HTML
  r
end

def parseable?(msg)
  return false if msg.nil? || msg.chars.first != '[' || msg.chars.last != ']'
  begin
    JSON.parse(msg)
    return true
  rescue JSON::ParserError => e
    return false
  end
end
