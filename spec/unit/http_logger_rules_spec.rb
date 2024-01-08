# coding: utf-8
# © 2016-2024 Graylog, Inc.

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLogger do

  it 'overrides default rules' do
    expect(HttpRules.default_rules).to eql(HttpRules.strict_rules)
    begin
      logger = HttpLogger.new(url: 'https://mysite.com')
      expect(logger.rules.text).to eql(HttpRules.strict_rules)
      logger = HttpLogger.new(url: 'https://mysite.com', rules: '# 123')
      expect(logger.rules.text).to eql('# 123')

      HttpRules.default_rules = ''
      logger = HttpLogger.new(url: 'https://mysite.com')
      expect(logger.rules.text).to eql('')
      logger = HttpLogger.new(url: 'https://mysite.com', rules: '   ')
      expect(logger.rules.text).to eql('')
      logger = HttpLogger.new(url: 'https://mysite.com', rules: ' sample 42')
      expect(logger.rules.text).to eql(' sample 42')

      HttpRules.default_rules = 'skip_compression'
      logger = HttpLogger.new(url: 'https://mysite.com')
      expect(logger.rules.text).to eql('skip_compression')
      logger = HttpLogger.new(url: 'https://mysite.com', rules: "include default\nskip_submission\n")
      expect(logger.rules.text).to eql("skip_compression\nskip_submission\n")

      HttpRules.default_rules = "sample 42\n"
      logger = HttpLogger.new(url: 'https://mysite.com')
      expect(logger.rules.text).to eql("sample 42\n")
      logger = HttpLogger.new(url: 'https://mysite.com', rules: '   ')
      expect(logger.rules.text).to eql("sample 42\n")
      logger = HttpLogger.new(url: 'https://mysite.com', rules: "include default\nskip_submission\n")
      expect(logger.rules.text).to eql("sample 42\n\nskip_submission\n")

      HttpRules.default_rules = "include debug"
      logger = HttpLogger.new(url: 'https://mysite.com', rules: HttpRules.strict_rules)
      expect(logger.rules.text).to eql(HttpRules.strict_rules)
    ensure
      HttpRules.default_rules = HttpRules.strict_rules
    end
  end

  it 'uses allow_http_url rules' do
    logger = HttpLogger.new(url: 'http://mysite.com')
    expect(logger.enableable?).to be false
    logger = HttpLogger.new(url: 'http://mysite.com', rules: '')
    expect(logger.enableable?).to be false
    logger = HttpLogger.new(url: 'https://mysite.com')
    expect(logger.enableable?).to be true
    logger = HttpLogger.new(url: 'http://mysite.com', rules: 'allow_http_url')
    expect(logger.enableable?).to be true
    logger = HttpLogger.new(url: 'http://mysite.com', rules: "allow_http_url\nallow_http_url")
    expect(logger.enableable?).to be true
  end

  it 'uses copy_session_field rules' do
    request = mock_request_with_json2
    request.session['butterfly'] = 'poison'
    request.session['session_id'] = 'asdf1234'

    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'copy_session_field /.*/')
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"session_field:butterfly\",\"poison\"]")).to be true
    expect(queue[0].include?("[\"session_field:session_id\",\"asdf1234\"]")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'copy_session_field /session_id/')
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"session_field:butterfly\",")).to be false
    expect(queue[0].include?("[\"session_field:session_id\",\"asdf1234\"]")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: 'copy_session_field /blah/')
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"session_field:")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "copy_session_field /butterfly/\ncopy_session_field /session_id/")
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"session_field:butterfly\",\"poison\"]")).to be true
    expect(queue[0].include?("[\"session_field:session_id\",\"asdf1234\"]")).to be true
  end

  it 'uses copy_session_field and remove rules' do
    request = mock_request_with_json2
    request.session['butterfly'] = 'poison'
    request.session['session_id'] = 'asdf1234'

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "copy_session_field !.*!\n!session_field:.*! remove")
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"session_field")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "copy_session_field !.*!\n!session_field:butterfly! remove")
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"session_field:butterfly\",")).to be false
    expect(queue[0].include?("[\"session_field:session_id\",\"asdf1234\"]")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "copy_session_field !.*!\n!session_field:.*! remove_if !poi.*!")
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"session_field:butterfly\",")).to be false
    expect(queue[0].include?("[\"session_field:session_id\",\"asdf1234\"]")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "copy_session_field !.*!\n!session_field:.*! remove_unless !sugar!")
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"session_field")).to be false
  end

  it 'uses copy_session_field and stop rules' do
    request = mock_request_with_json2
    request.session['butterfly'] = 'poison'
    request.session['session_id'] = 'asdf1234'

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "copy_session_field !.*!\n!session_field:butterfly! stop")
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "copy_session_field !.*!\n!session_field:butterfly! stop_if !poi.*!")
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "copy_session_field !.*!\n!session_field:butterfly! stop_unless !sugar!")
    HttpMessage.send(logger, request, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0
  end

  it 'uses remove rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!.*! remove')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!request_body! remove')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! remove')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!request_body|response_body! remove')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!request_header:.*! remove')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"request_header:")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "!request_header:abc! remove\n!response_body! remove")
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"request_header:")).to be true
    expect(queue[0].include?("[\"request_header:abc\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be false
  end

  it 'uses remove_if rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_header:blahblahblah! remove_if !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!.*! remove_if !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!request_body! remove_if !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! remove_if !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_if !.*World.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_if !.*blahblahblah.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "!request_body! remove_if !.*!\n!response_body! remove_if !.*!")
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be false
  end

  it 'uses remove_if_found rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_header:blahblahblah! remove_if_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!.*! remove_if_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!request_body! remove_if_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! remove_if_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_if_found !World!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_if_found !.*World.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_if_found !blahblahblah!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be true
  end

  it 'uses remove_unless rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_header:blahblahblah! remove_unless !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!.*! remove_unless !.*blahblahblah.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!request_body! remove_unless !.*blahblahblah.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! remove_unless !.*blahblahblah.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_unless !.*World.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_unless !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "!response_body! remove_unless !.*!\n!request_body! remove_unless !.*!")
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be true
  end

  it 'uses remove_unless_found rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_header:blahblahblah! remove_unless_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!.*! remove_unless_found !blahblahblah!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!request_body! remove_unless_found !blahblahblah!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! remove_unless_found !blahblahblah!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_unless_found !World!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_unless_found !.*World.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be false
    expect(queue[0].include?("[\"response_body\",")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body|request_body! remove_unless_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",")).to be true
    expect(queue[0].include?("[\"response_body\",")).to be true
  end

  it 'uses replace rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! replace !blahblahblah!, !ZZZZZ!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?('World')).to be true
    expect(queue[0].include?('ZZZZZ')).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! replace !World!, !Mundo!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",\"<html>Hello Mundo!</html>\"],")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!request_body|response_body! replace !^.*!, !ZZZZZ!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",\"ZZZZZ\"")).to be true
    expect(queue[0].include?("[\"response_body\",\"ZZZZZ\"")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "!request_body! replace !^.*!, !QQ!\n!response_body! replace !^.*!, !SS!")
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"request_body\",\"QQ\"")).to be true
    expect(queue[0].include?("[\"response_body\",\"SS\"")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! replace !World!, !!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",\"<html>Hello !</html>\"],")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! replace !.*!, !!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",")).to be false

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! replace !World!, !Z!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML3, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",\"<html>1 Z 2 Z Red Z Blue Z!</html>\"],")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! replace !World!, !Z!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML4, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",\"<html>1 Z\\n2 Z\\nRed Z \\nBlue Z!\\n</html>\"],")).to be true
  end

  it 'uses replace rules with complex expressions' do
    queue = []
    logger = HttpLogger.new(
        queue: queue,
        rules: %q(/response_body/ replace /[a-zA-Z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)/, /x@y.com/)
    )
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML.gsub('World', 'rob@resurface.io'), MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",\"<html>Hello x@y.com!</html>\"],")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: %q(/response_body/ replace /[0-9\.\-\/]{9,}/, /xyxy/))
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML.gsub('World', '123-45-1343'), MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",\"<html>Hello xyxy!</html>\"],")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! replace !World!, !<b>\\0</b>!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",\"<html>Hello <b>World</b>!</html>\"],")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! replace !(World)!, !<b>\\1</b>!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",\"<html>Hello <b>World</b>!</html>\"],")).to be true

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "!response_body! replace !<input([^>]*)>([^<]*)</input>!, !<input\\1></input>!")
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML5, MOCK_JSON)
    expect(queue.length).to be 1
    expect(queue[0].include?("[\"response_body\",\"<html>\\n<input type=\\\"hidden\\\"></input>\\n<input class='foo' type=\\\"hidden\\\"></input>\\n</html>\"],")).to be true
  end

  it 'uses sample rules' do
    queue = []

    begin
      HttpLogger.new(queue: queue, rules: "sample 10\nsample 99")
      expect(false).to be true
    rescue RuntimeError => e
      expect(e.message).to eql('Multiple sample rules')
    end

    logger = HttpLogger.new(queue: queue, rules: 'sample 10')
    (1..100).each {HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html)}
    expect(queue.length).to be > 2
    expect(queue.length).to be < 20
  end

  it 'uses skip_compression rules' do
    logger = HttpLogger.new(url: 'http://mysite.com')
    expect(logger.skip_compression?).to be false
    logger = HttpLogger.new(url: 'http://mysite.com', rules: '')
    expect(logger.skip_compression?).to be false
    logger = HttpLogger.new(url: 'http://mysite.com', rules: 'skip_compression')
    expect(logger.skip_compression?).to be true
  end

  it 'uses skip_submission rules' do
    logger = HttpLogger.new(url: 'http://mysite.com')
    expect(logger.skip_submission?).to be false
    logger = HttpLogger.new(url: 'http://mysite.com', rules: '')
    expect(logger.skip_submission?).to be false
    logger = HttpLogger.new(url: 'http://mysite.com', rules: 'skip_submission')
    expect(logger.skip_submission?).to be true
  end

  it 'uses stop rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_header:blahblahblah! stop')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!.*! stop')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!request_body! stop')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, nil, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: "!request_body! stop\n!response_body! stop")
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, nil, MOCK_JSON)
    expect(queue.length).to be 0
  end

  it 'uses stop_if rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_header:blahblahblah! stop_if !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_if !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_if !.*World.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_if !.*blahblahblah.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
  end

  it 'uses stop_if_found rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_header:blahblahblah! stop_if_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_if_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_if_found !World!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_if_found !.*World.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_if_found !blahblahblah!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, MOCK_JSON)
    expect(queue.length).to be 1
  end

  it 'uses stop_unless rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_header:blahblahblah! stop_unless !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_unless !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_unless !.*World.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_unless !.*blahblahblah.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 0
  end

  it 'uses stop_unless_found rules' do
    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_header:blahblahblah! stop_unless_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 0

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_unless_found !.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_unless_found !World!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_unless_found !.*World.*!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 1

    queue = []
    logger = HttpLogger.new(queue: queue, rules: '!response_body! stop_unless_found !blahblahblah!')
    HttpMessage.send(logger, mock_request_with_json2, mock_response_with_html, MOCK_HTML, nil)
    expect(queue.length).to be 0
  end

end
