# coding: utf-8
# © 2016-2018 Resurface Labs LLC

require 'resurfaceio/all'

describe HttpRules do

  it 'includes standard rules' do
    rules = HttpRules.parse('include standard')
    expect(rules.length).to eql(3)
    expect(rules.select {|r| 'remove' == r.verb}.length).to eql(1)
    expect(rules.select {|r| 'replace' == r.verb}.length).to eql(2)

    rules = HttpRules.parse("include standard\n")
    expect(rules.length).to eql(3)
    rules = HttpRules.parse("include standard\nsample 50")
    expect(rules.length).to eql(4)
    expect(rules.select {|r| 'sample' == r.verb}.length).to eql(1)

    rules = HttpRules.parse(" include standard\ninclude standard\n")
    expect(rules.length).to eql(6)
    rules = HttpRules.parse("include standard\nsample 50\ninclude standard")
    expect(rules.length).to eql(7)
  end

  it 'includes debug rules' do
    rules = HttpRules.parse('include debug')
    expect(rules.length).to eql(2)
    expect(rules.select {|r| 'allow_http_url' == r.verb}.length).to eql(1)
    expect(rules.select {|r| 'copy_session_field' == r.verb}.length).to eql(1)

    rules = HttpRules.parse("include debug\n")
    expect(rules.length).to eql(2)
    rules = HttpRules.parse("include debug\nsample 50")
    expect(rules.length).to eql(3)
    expect(rules.select {|r| 'sample' == r.verb}.length).to eql(1)

    rules = HttpRules.parse(" include debug\ninclude debug\n")
    expect(rules.length).to eql(4)
    rules = HttpRules.parse("include debug\nsample 50\ninclude debug")
    expect(rules.length).to eql(5)
  end

  it 'includes weblog rules' do
    rules = HttpRules.parse('include weblog')
    expect(rules.length).to eql(2)
    expect(rules.select {|r| 'remove' == r.verb}.length).to eql(1)
    expect(rules.select {|r| 'replace' == r.verb}.length).to eql(1)

    rules = HttpRules.parse("include weblog\n")
    expect(rules.length).to eql(2)
    rules = HttpRules.parse("include weblog\nsample 50")
    expect(rules.length).to eql(3)
    expect(rules.select {|r| 'sample' == r.verb}.length).to eql(1)

    rules = HttpRules.parse(" include weblog\ninclude weblog\n")
    expect(rules.length).to eql(4)
    rules = HttpRules.parse("include weblog\nsample 50\ninclude weblog")
    expect(rules.length).to eql(5)
  end

  def parse_fail(line)
    begin
      HttpRules.parse_rule(line)
    rescue RuntimeError
      return
    end
    expect(false).to be true
  end

  def parse_ok(line, verb, scope, param1, param2)
    rule = HttpRules.parse_rule(line)
    expect(rule.verb).to eql(verb)
    expect(rule.scope.respond_to?(:source) ? rule.scope.source : rule.scope).to eql(scope)
    expect(rule.param1.respond_to?(:source) ? rule.param1.source : rule.param1).to eql(param1)
    expect(rule.param2.respond_to?(:source) ? rule.param2.source : rule.param2).to eql(param2)
  end

  it 'parses empty rules' do
    expect(HttpRules.parse(nil).size).to be 0
    expect(HttpRules.parse("").size).to be 0
    expect(HttpRules.parse(" ").size).to be 0
    expect(HttpRules.parse("\t").size).to be 0
    expect(HttpRules.parse("\n").size).to be 0

    expect(HttpRules.parse_rule(nil)).to be nil
    expect(HttpRules.parse_rule("")).to be nil
    expect(HttpRules.parse_rule(" ")).to be nil
    expect(HttpRules.parse_rule("\t")).to be nil
    expect(HttpRules.parse_rule("\n")).to be nil
  end

  it 'parses rules with bad verbs' do
    %w(b bozo '*' '.*').each do |v|
      parse_fail("#{v}")
      parse_fail("!.*! #{v}")
      parse_fail("/.*/ #{v}")
      parse_fail("%request_body% #{v}")
      parse_fail("/^request_header:.*/ #{v}")
    end
  end

  it 'parses rules with invalid scopes' do
    %w(request_body '*' '.*').each do |s|
      parse_fail("/#{s}")
      parse_fail("/#{s}# 1")
      parse_fail("/#{s} # 1")
      parse_fail("/#{s}/")
      parse_fail("/#{s}/ # 1")
      parse_fail(" / #{s}")
      parse_fail("// #{s}")
      parse_fail("/// #{s}")
      parse_fail("/* #{s}")
      parse_fail("/? #{s}")
      parse_fail("/+ #{s}")
      parse_fail("/( #{s}")
      parse_fail("/(.* #{s}")
      parse_fail("/(.*)) #{s}")

      parse_fail("~#{s}")
      parse_fail("!#{s}# 1")
      parse_fail("|#{s} # 1")
      parse_fail("|#{s}|")
      parse_fail("%#{s}% # 1")
      parse_fail(" % #{s}")
      parse_fail("%% #{s}")
      parse_fail("%%% #{s}")
      parse_fail("%* #{s}")
      parse_fail("%? #{s}")
      parse_fail("%+ #{s}")
      parse_fail("%( #{s}")
      parse_fail("%(.* #{s}")
      parse_fail("%(.*)) #{s}")

      parse_fail("~#{s}%")
      parse_fail("!#{s}%# 1")
      parse_fail("|#{s}% # 1")
      parse_fail("|#{s}%")
      parse_fail("%#{s}| # 1")
      parse_fail("~(.*! #{s}")
      parse_fail("~(.*))! #{s}")
      parse_fail("/(.*! #{s}")
      parse_fail("/(.*))! #{s}")
    end
  end

  it 'parses allow_http_url rules' do
    parse_fail("allow_http_url whaa")
    parse_ok("allow_http_url", "allow_http_url", nil, nil, nil)
    parse_ok("allow_http_url # be safe bro!", "allow_http_url", nil, nil, nil)
  end

  it 'parses copy_session_field rules' do
    # with extra params
    parse_fail("|.*| copy_session_field %1%, %2%")
    parse_fail("!.*! copy_session_field /1/, 2")
    parse_fail("/.*/ copy_session_field /1/, /2")
    parse_fail("/.*/ copy_session_field /1/, /2/")
    parse_fail("/.*/ copy_session_field /1/, /2/, /3/ # blah")
    parse_fail("!.*! copy_session_field %1%, %2%, %3%")
    parse_fail("/.*/ copy_session_field /1/, /2/, 3")
    parse_fail("/.*/ copy_session_field /1/, /2/, /3")
    parse_fail("/.*/ copy_session_field /1/, /2/, /3/")
    parse_fail("%.*% copy_session_field /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! copy_session_field")
    parse_fail("/.*/ copy_session_field")
    parse_fail("/.*/ copy_session_field /")
    parse_fail("/.*/ copy_session_field //")
    parse_fail("/.*/ copy_session_field blah")
    parse_fail("/.*/ copy_session_field # bleep")
    parse_fail("/.*/ copy_session_field blah # bleep")

    # with invalid params
    parse_fail("/.*/ copy_session_field /")
    parse_fail("/.*/ copy_session_field //")
    parse_fail("/.*/ copy_session_field ///")
    parse_fail("/.*/ copy_session_field /*/")
    parse_fail("/.*/ copy_session_field /?/")
    parse_fail("/.*/ copy_session_field /+/")
    parse_fail("/.*/ copy_session_field /(/")
    parse_fail("/.*/ copy_session_field /(.*/")
    parse_fail("/.*/ copy_session_field /(.*))/")

    # with valid regexes
    parse_ok("copy_session_field !.*!", "copy_session_field", nil, "^.*$", nil)
    parse_ok("copy_session_field /.*/", "copy_session_field", nil, "^.*$", nil)
    parse_ok("copy_session_field /^.*/", "copy_session_field", nil, "^.*$", nil)
    parse_ok("copy_session_field /.*$/", "copy_session_field", nil, "^.*$", nil)
    parse_ok("copy_session_field /^.*$/", "copy_session_field", nil, "^.*$", nil)

    # with valid regexes and escape sequences
    parse_ok("copy_session_field !A\\!|B!", "copy_session_field", nil, "^A!|B$", nil)
    parse_ok("copy_session_field |A\\|B|", "copy_session_field", nil, "^A|B$", nil)
    parse_ok("copy_session_field |A\\|B\\|C|", "copy_session_field", nil, "^A|B|C$", nil)
    parse_ok("copy_session_field /A\\/B\\/C/", "copy_session_field", nil, "^A/B/C$", nil)
  end

  it 'parses remove rules' do
    # with extra params
    parse_fail("|.*| remove %1%")
    parse_fail("~.*~ remove 1")
    parse_fail("/.*/ remove /1/")
    parse_fail("/.*/ remove 1 # bleep")
    parse_fail("|.*| remove %1%, %2%")
    parse_fail("!.*! remove /1/, 2")
    parse_fail("/.*/ remove /1/, /2")
    parse_fail("/.*/ remove /1/, /2/")
    parse_fail("/.*/ remove /1/, /2/, /3/ # blah")
    parse_fail("!.*! remove %1%, %2%, %3%")
    parse_fail("/.*/ remove /1/, /2/, 3")
    parse_fail("/.*/ remove /1/, /2/, /3")
    parse_fail("/.*/ remove /1/, /2/, /3/")
    parse_fail("%.*% remove /1/, /2/, /3/ # blah")

    # with valid regexes
    parse_ok("%request_header:cookie|response_header:set-cookie% remove",
             "remove", "^request_header:cookie|response_header:set-cookie$", nil, nil)
    parse_ok("/request_header:cookie|response_header:set-cookie/ remove",
             "remove", "^request_header:cookie|response_header:set-cookie$", nil, nil)

    # with valid regexes and escape sequences
    parse_ok("!request_header\\!|response_header:set-cookie! remove",
             "remove", "^request_header!|response_header:set-cookie$", nil, nil)
    parse_ok("|request_header:cookie\\|response_header:set-cookie| remove",
             "remove", "^request_header:cookie|response_header:set-cookie$", nil, nil)
    parse_ok("|request_header:cookie\\|response_header:set-cookie\\|boo| remove",
             "remove", "^request_header:cookie|response_header:set-cookie|boo$", nil, nil)
    parse_ok("/request_header:cookie\\/response_header:set-cookie\\/boo/ remove",
             "remove", "^request_header:cookie/response_header:set-cookie/boo$", nil, nil)
  end

  it 'parses remove_if rules' do
    # with extra params
    parse_fail("|.*| remove_if %1%, %2%")
    parse_fail("!.*! remove_if /1/, 2")
    parse_fail("/.*/ remove_if /1/, /2")
    parse_fail("/.*/ remove_if /1/, /2/")
    parse_fail("/.*/ remove_if /1/, /2/, /3/ # blah")
    parse_fail("!.*! remove_if %1%, %2%, %3%")
    parse_fail("/.*/ remove_if /1/, /2/, 3")
    parse_fail("/.*/ remove_if /1/, /2/, /3")
    parse_fail("/.*/ remove_if /1/, /2/, /3/")
    parse_fail("%.*% remove_if /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! remove_if")
    parse_fail("/.*/ remove_if")
    parse_fail("/.*/ remove_if /")
    parse_fail("/.*/ remove_if //")
    parse_fail("/.*/ remove_if blah")
    parse_fail("/.*/ remove_if # bleep")
    parse_fail("/.*/ remove_if blah # bleep")

    # with invalid params
    parse_fail("/.*/ remove_if /")
    parse_fail("/.*/ remove_if //")
    parse_fail("/.*/ remove_if ///")
    parse_fail("/.*/ remove_if /*/")
    parse_fail("/.*/ remove_if /?/")
    parse_fail("/.*/ remove_if /+/")
    parse_fail("/.*/ remove_if /(/")
    parse_fail("/.*/ remove_if /(.*/")
    parse_fail("/.*/ remove_if /(.*))/")

    # with valid regexes
    parse_ok("%response_body% remove_if %<!--SKIP_BODY_LOGGING-->%",
             "remove_if", "^response_body$", "^<!--SKIP_BODY_LOGGING-->$", nil)
    parse_ok("/response_body/ remove_if /<!--SKIP_BODY_LOGGING-->/",
             "remove_if", "^response_body$", "^<!--SKIP_BODY_LOGGING-->$", nil)

    # with valid regexes and escape sequences
    parse_ok("!request_body|response_body! remove_if |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "remove_if", "^request_body|response_body$", "^<!--IGNORE_LOGGING-->|<!-SKIP-->$", nil)
    parse_ok("|request_body\\|response_body| remove_if |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "remove_if", "^request_body|response_body$", "^<!--IGNORE_LOGGING-->|<!-SKIP-->$", nil)
    parse_ok("|request_body\\|response_body\\|boo| remove_if |<!--IGNORE_LOGGING-->\\|<!-SKIP-->\\|asdf|",
             "remove_if", "^request_body|response_body|boo$", "^<!--IGNORE_LOGGING-->|<!-SKIP-->|asdf$", nil)
    parse_ok("/request_body\\/response_body\\/boo/ remove_if |<!--IGNORE_LOGGING-->\\|<!-SKIP-->\\|asdf|",
             "remove_if", "^request_body/response_body/boo$", "^<!--IGNORE_LOGGING-->|<!-SKIP-->|asdf$", nil)
  end

  it 'parses remove_if_found rules' do
    # with extra params
    parse_fail("|.*| remove_if_found %1%, %2%")
    parse_fail("!.*! remove_if_found /1/, 2")
    parse_fail("/.*/ remove_if_found /1/, /2")
    parse_fail("/.*/ remove_if_found /1/, /2/")
    parse_fail("/.*/ remove_if_found /1/, /2/, /3/ # blah")
    parse_fail("!.*! remove_if_found %1%, %2%, %3%")
    parse_fail("/.*/ remove_if_found /1/, /2/, 3")
    parse_fail("/.*/ remove_if_found /1/, /2/, /3")
    parse_fail("/.*/ remove_if_found /1/, /2/, /3/")
    parse_fail("%.*% remove_if_found /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! remove_if_found")
    parse_fail("/.*/ remove_if_found")
    parse_fail("/.*/ remove_if_found /")
    parse_fail("/.*/ remove_if_found //")
    parse_fail("/.*/ remove_if_found blah")
    parse_fail("/.*/ remove_if_found # bleep")
    parse_fail("/.*/ remove_if_found blah # bleep")

    # with invalid params
    parse_fail("/.*/ remove_if_found /")
    parse_fail("/.*/ remove_if_found //")
    parse_fail("/.*/ remove_if_found ///")
    parse_fail("/.*/ remove_if_found /*/")
    parse_fail("/.*/ remove_if_found /?/")
    parse_fail("/.*/ remove_if_found /+/")
    parse_fail("/.*/ remove_if_found /(/")
    parse_fail("/.*/ remove_if_found /(.*/")
    parse_fail("/.*/ remove_if_found /(.*))/")

    # with valid regexes
    parse_ok("%response_body% remove_if_found %<!--SKIP_BODY_LOGGING-->%",
             "remove_if_found", "^response_body$", "<!--SKIP_BODY_LOGGING-->", nil)
    parse_ok("/response_body/ remove_if_found /<!--SKIP_BODY_LOGGING-->/",
             "remove_if_found", "^response_body$", "<!--SKIP_BODY_LOGGING-->", nil)

    # with valid regexes and escape sequences
    parse_ok("!request_body|response_body! remove_if_found |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "remove_if_found", "^request_body|response_body$", "<!--IGNORE_LOGGING-->|<!-SKIP-->", nil)
    parse_ok("|request_body\\|response_body| remove_if_found |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "remove_if_found", "^request_body|response_body$", "<!--IGNORE_LOGGING-->|<!-SKIP-->", nil)
    parse_ok("|request_body\\|response_body\\|boo| remove_if_found |<!--IGNORE_LOGGING-->\\|<!-SKIP-->\\|asdf|",
             "remove_if_found", "^request_body|response_body|boo$", "<!--IGNORE_LOGGING-->|<!-SKIP-->|asdf", nil)
    parse_ok("/request_body\\/response_body\\/boo/ remove_if_found |<!--IGNORE_LOGGING-->\\|<!-SKIP-->\\|asdf|",
             "remove_if_found", "^request_body/response_body/boo$", "<!--IGNORE_LOGGING-->|<!-SKIP-->|asdf", nil)
  end

  it 'parses remove_unless rules' do
    # with extra params
    parse_fail("|.*| remove_unless %1%, %2%")
    parse_fail("!.*! remove_unless /1/, 2")
    parse_fail("/.*/ remove_unless /1/, /2")
    parse_fail("/.*/ remove_unless /1/, /2/")
    parse_fail("/.*/ remove_unless /1/, /2/, /3/ # blah")
    parse_fail("!.*! remove_unless %1%, %2%, %3%")
    parse_fail("/.*/ remove_unless /1/, /2/, 3")
    parse_fail("/.*/ remove_unless /1/, /2/, /3")
    parse_fail("/.*/ remove_unless /1/, /2/, /3/")
    parse_fail("%.*% remove_unless /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! remove_unless")
    parse_fail("/.*/ remove_unless")
    parse_fail("/.*/ remove_unless /")
    parse_fail("/.*/ remove_unless //")
    parse_fail("/.*/ remove_unless blah")
    parse_fail("/.*/ remove_unless # bleep")
    parse_fail("/.*/ remove_unless blah # bleep")

    # with invalid params
    parse_fail("/.*/ remove_unless /")
    parse_fail("/.*/ remove_unless //")
    parse_fail("/.*/ remove_unless ///")
    parse_fail("/.*/ remove_unless /*/")
    parse_fail("/.*/ remove_unless /?/")
    parse_fail("/.*/ remove_unless /+/")
    parse_fail("/.*/ remove_unless /(/")
    parse_fail("/.*/ remove_unless /(.*/")
    parse_fail("/.*/ remove_unless /(.*))/")

    # with valid regexes
    parse_ok("%response_body% remove_unless %<!--PERFORM_BODY_LOGGING-->%",
             "remove_unless", "^response_body$", "^<!--PERFORM_BODY_LOGGING-->$", nil)
    parse_ok("/response_body/ remove_unless /<!--PERFORM_BODY_LOGGING-->/",
             "remove_unless", "^response_body$", "^<!--PERFORM_BODY_LOGGING-->$", nil)

    # with valid regexes and escape sequences
    parse_ok("!request_body|response_body! remove_unless |<!--PERFORM_LOGGING-->\\|<!-SKIP-->|",
             "remove_unless", "^request_body|response_body$", "^<!--PERFORM_LOGGING-->|<!-SKIP-->$", nil)
    parse_ok("|request_body\\|response_body| remove_unless |<!--PERFORM_LOGGING-->\\|<!-SKIP-->|",
             "remove_unless", "^request_body|response_body$", "^<!--PERFORM_LOGGING-->|<!-SKIP-->$", nil)
    parse_ok("|request_body\\|response_body\\|boo| remove_unless |<!--PERFORM_LOGGING-->\\|<!-SKIP-->\\|skipit|",
             "remove_unless", "^request_body|response_body|boo$", "^<!--PERFORM_LOGGING-->|<!-SKIP-->|skipit$", nil)
    parse_ok("/request_body\\/response_body\\/boo/ remove_unless |<!--PERFORM_LOGGING-->\\|<!-SKIP-->\\|skipit|",
             "remove_unless", "^request_body/response_body/boo$", "^<!--PERFORM_LOGGING-->|<!-SKIP-->|skipit$", nil)
  end

  it 'parses remove_unless_found rules' do
    # with extra params
    parse_fail("|.*| remove_unless_found %1%, %2%")
    parse_fail("!.*! remove_unless_found /1/, 2")
    parse_fail("/.*/ remove_unless_found /1/, /2")
    parse_fail("/.*/ remove_unless_found /1/, /2/")
    parse_fail("/.*/ remove_unless_found /1/, /2/, /3/ # blah")
    parse_fail("!.*! remove_unless_found %1%, %2%, %3%")
    parse_fail("/.*/ remove_unless_found /1/, /2/, 3")
    parse_fail("/.*/ remove_unless_found /1/, /2/, /3")
    parse_fail("/.*/ remove_unless_found /1/, /2/, /3/")
    parse_fail("%.*% remove_unless_found /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! remove_unless_found")
    parse_fail("/.*/ remove_unless_found")
    parse_fail("/.*/ remove_unless_found /")
    parse_fail("/.*/ remove_unless_found //")
    parse_fail("/.*/ remove_unless_found blah")
    parse_fail("/.*/ remove_unless_found # bleep")
    parse_fail("/.*/ remove_unless_found blah # bleep")

    # with invalid params
    parse_fail("/.*/ remove_unless_found /")
    parse_fail("/.*/ remove_unless_found //")
    parse_fail("/.*/ remove_unless_found ///")
    parse_fail("/.*/ remove_unless_found /*/")
    parse_fail("/.*/ remove_unless_found /?/")
    parse_fail("/.*/ remove_unless_found /+/")
    parse_fail("/.*/ remove_unless_found /(/")
    parse_fail("/.*/ remove_unless_found /(.*/")
    parse_fail("/.*/ remove_unless_found /(.*))/")

    # with valid regexes
    parse_ok("%response_body% remove_unless_found %<!--PERFORM_BODY_LOGGING-->%",
             "remove_unless_found", "^response_body$", "<!--PERFORM_BODY_LOGGING-->", nil)
    parse_ok("/response_body/ remove_unless_found /<!--PERFORM_BODY_LOGGING-->/",
             "remove_unless_found", "^response_body$", "<!--PERFORM_BODY_LOGGING-->", nil)

    # with valid regexes and escape sequences
    parse_ok("!request_body|response_body! remove_unless_found |<!--PERFORM_LOGGING-->\\|<!-SKIP-->|",
             "remove_unless_found", "^request_body|response_body$", "<!--PERFORM_LOGGING-->|<!-SKIP-->", nil)
    parse_ok("|request_body\\|response_body| remove_unless_found |<!--PERFORM_LOGGING-->\\|<!-SKIP-->|",
             "remove_unless_found", "^request_body|response_body$", "<!--PERFORM_LOGGING-->|<!-SKIP-->", nil)
    parse_ok("|request_body\\|response_body\\|boo| remove_unless_found |<!--PERFORM_LOGGING-->\\|<!-SKIP-->\\|skipit|",
             "remove_unless_found", "^request_body|response_body|boo$", "<!--PERFORM_LOGGING-->|<!-SKIP-->|skipit", nil)
    parse_ok("/request_body\\/response_body\\/boo/ remove_unless_found |<!--PERFORM_LOGGING-->\\|<!-SKIP-->\\|skipit|",
             "remove_unless_found", "^request_body/response_body/boo$", "<!--PERFORM_LOGGING-->|<!-SKIP-->|skipit", nil)
  end

  it 'parses replace rules' do
    # with extra params
    parse_fail("!.*! replace %1%, %2%, %3%")
    parse_fail("/.*/ replace /1/, /2/, 3")
    parse_fail("/.*/ replace /1/, /2/, /3")
    parse_fail("/.*/ replace /1/, /2/, /3/")
    parse_fail("%.*% replace /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! replace")
    parse_fail("/.*/ replace")
    parse_fail("/.*/ replace /")
    parse_fail("/.*/ replace //")
    parse_fail("/.*/ replace blah")
    parse_fail("/.*/ replace # bleep")
    parse_fail("/.*/ replace blah # bleep")
    parse_fail("!.*! replace boo yah")
    parse_fail("/.*/ replace boo yah")
    parse_fail("/.*/ replace boo yah # bro")
    parse_fail("/.*/ replace /.*/ # bleep")
    parse_fail("/.*/ replace /.*/, # bleep")
    parse_fail("/.*/ replace /.*/, /# bleep")
    parse_fail("/.*/ replace // # bleep")
    parse_fail("/.*/ replace // // # bleep")

    # with invalid params
    parse_fail("/.*/ replace /")
    parse_fail("/.*/ replace //")
    parse_fail("/.*/ replace ///")
    parse_fail("/.*/ replace /*/")
    parse_fail("/.*/ replace /?/")
    parse_fail("/.*/ replace /+/")
    parse_fail("/.*/ replace /(/")
    parse_fail("/.*/ replace /(.*/")
    parse_fail("/.*/ replace /(.*))/")
    parse_fail("/.*/ replace /1/, ~")
    parse_fail("/.*/ replace /1/, !")
    parse_fail("/.*/ replace /1/, %")
    parse_fail("/.*/ replace /1/, |")
    parse_fail("/.*/ replace /1/, /")

    # with valid regexes
    parse_ok("%response_body% replace %kurt%, %vagner%", "replace", "^response_body$", "kurt", "vagner")
    parse_ok("/response_body/ replace /kurt/, /vagner/", "replace", "^response_body$", "kurt", "vagner")
    parse_ok("%response_body|.+_header:.+% replace %kurt%, %vagner%",
             "replace", "^response_body|.+_header:.+$", "kurt", "vagner")
    parse_ok("|response_body\\|.+_header:.+| replace |kurt|, |vagner\\|frazier|",
             "replace", "^response_body|.+_header:.+$", "kurt", "vagner|frazier")

    # with valid regexes and escape sequences
    parse_ok("|response_body\\|.+_header:.+| replace |kurt|, |vagner|",
             "replace", "^response_body|.+_header:.+$", "kurt", "vagner")
    parse_ok("|response_body\\|.+_header:.+\\|boo| replace |kurt|, |vagner|",
             "replace", "^response_body|.+_header:.+|boo$", "kurt", "vagner")
    parse_ok("|response_body| replace |kurt\\|bruce|, |vagner|",
             "replace", "^response_body$", "kurt|bruce", "vagner")
    parse_ok("|response_body| replace |kurt\\|bruce\\|kevin|, |vagner|",
             "replace", "^response_body$", "kurt|bruce|kevin", "vagner")
    parse_ok("|response_body| replace /kurt\\/bruce\\/kevin/, |vagner|",
             "replace", "^response_body$", "kurt/bruce/kevin", "vagner")
  end

  it 'parses sample rules' do
    parse_fail("sample")
    parse_fail("sample 50 50")
    parse_fail("sample 0")
    parse_fail("sample 100")
    parse_fail("sample 105")
    parse_fail("sample 10.5")
    parse_fail("sample blue")
    parse_fail("sample # bleep")
    parse_fail("sample blue # bleep")
    parse_fail("sample //")
    parse_fail("sample /42/")
    parse_ok("sample 50", "sample", nil, 50, nil)
    parse_ok("sample 72 # comment", "sample", nil, 72, nil)
  end

  it 'parses skip_compression rules' do
    parse_fail("skip_compression whaa")
    parse_ok("skip_compression", "skip_compression", nil, nil, nil)
    parse_ok("skip_compression # slightly faster!", "skip_compression", nil, nil, nil)
  end

  it 'parses skip_submission rules' do
    parse_fail("skip_submission whaa")
    parse_ok("skip_submission", "skip_submission", nil, nil, nil)
    parse_ok("skip_submission # slightly faster!", "skip_submission", nil, nil, nil)
  end

  it 'parses stop rules' do
    # with extra params
    parse_fail("|.*| stop %1%")
    parse_fail("~.*~ stop 1")
    parse_fail("/.*/ stop /1/")
    parse_fail("/.*/ stop 1 # bleep")
    parse_fail("|.*| stop %1%, %2%")
    parse_fail("!.*! stop /1/, 2")
    parse_fail("/.*/ stop /1/, /2")
    parse_fail("/.*/ stop /1/, /2/")
    parse_fail("/.*/ stop /1/, /2/, /3/ # blah")
    parse_fail("!.*! stop %1%, %2%, %3%")
    parse_fail("/.*/ stop /1/, /2/, 3")
    parse_fail("/.*/ stop /1/, /2/, /3")
    parse_fail("/.*/ stop /1/, /2/, /3/")
    parse_fail("%.*% stop /1/, /2/, /3/ # blah")

    # with valid regexes
    parse_ok("%request_header:skip_usage_logging% stop", "stop", "^request_header:skip_usage_logging$", nil, nil)
    parse_ok("|request_header:skip_usage_logging| stop", "stop", "^request_header:skip_usage_logging$", nil, nil)
    parse_ok("/request_header:skip_usage_logging/ stop", "stop", "^request_header:skip_usage_logging$", nil, nil)

    # with valid regexes and escape sequences
    parse_ok("!request_header\\!! stop", "stop", "^request_header!$", nil, nil)
    parse_ok("|request_header\\|response_header| stop", "stop", "^request_header|response_header$", nil, nil)
    parse_ok("|request_header\\|response_header\\|boo| stop", "stop", "^request_header|response_header|boo$", nil, nil)
    parse_ok("/request_header\\/response_header\\/boo/ stop", "stop", "^request_header/response_header/boo$", nil, nil)
  end

  it 'parses stop_if rules' do
    # with extra params
    parse_fail("|.*| stop_if %1%, %2%")
    parse_fail("!.*! stop_if /1/, 2")
    parse_fail("/.*/ stop_if /1/, /2")
    parse_fail("/.*/ stop_if /1/, /2/")
    parse_fail("/.*/ stop_if /1/, /2/, /3/ # blah")
    parse_fail("!.*! stop_if %1%, %2%, %3%")
    parse_fail("/.*/ stop_if /1/, /2/, 3")
    parse_fail("/.*/ stop_if /1/, /2/, /3")
    parse_fail("/.*/ stop_if /1/, /2/, /3/")
    parse_fail("%.*% stop_if /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! stop_if")
    parse_fail("/.*/ stop_if")
    parse_fail("/.*/ stop_if /")
    parse_fail("/.*/ stop_if //")
    parse_fail("/.*/ stop_if blah")
    parse_fail("/.*/ stop_if # bleep")
    parse_fail("/.*/ stop_if blah # bleep")

    # with invalid params
    parse_fail("/.*/ stop_if /")
    parse_fail("/.*/ stop_if //")
    parse_fail("/.*/ stop_if ///")
    parse_fail("/.*/ stop_if /*/")
    parse_fail("/.*/ stop_if /?/")
    parse_fail("/.*/ stop_if /+/")
    parse_fail("/.*/ stop_if /(/")
    parse_fail("/.*/ stop_if /(.*/")
    parse_fail("/.*/ stop_if /(.*))/")

    # with valid regexes
    parse_ok("%response_body% stop_if %<!--IGNORE_LOGGING-->%", "stop_if", "^response_body$", "^<!--IGNORE_LOGGING-->$", nil)
    parse_ok("/response_body/ stop_if /<!--IGNORE_LOGGING-->/", "stop_if", "^response_body$", "^<!--IGNORE_LOGGING-->$", nil)

    # with valid regexes and escape sequences
    parse_ok("!request_body|response_body! stop_if |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "stop_if", "^request_body|response_body$", "^<!--IGNORE_LOGGING-->|<!-SKIP-->$", nil)
    parse_ok("!request_body|response_body|boo\\!! stop_if |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "stop_if", "^request_body|response_body|boo!$", "^<!--IGNORE_LOGGING-->|<!-SKIP-->$", nil)
    parse_ok("|request_body\\|response_body| stop_if |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "stop_if", "^request_body|response_body$", "^<!--IGNORE_LOGGING-->|<!-SKIP-->$", nil)
    parse_ok("/request_body\\/response_body/ stop_if |<!--IGNORE_LOGGING-->\\|<!-SKIP-->\\|pipe\\||",
             "stop_if", "^request_body/response_body$", "^<!--IGNORE_LOGGING-->|<!-SKIP-->|pipe|$", nil)
  end

  it 'parses stop_if_found rules' do
    # with extra params
    parse_fail("|.*| stop_if_found %1%, %2%")
    parse_fail("!.*! stop_if_found /1/, 2")
    parse_fail("/.*/ stop_if_found /1/, /2")
    parse_fail("/.*/ stop_if_found /1/, /2/")
    parse_fail("/.*/ stop_if_found /1/, /2/, /3/ # blah")
    parse_fail("!.*! stop_if_found %1%, %2%, %3%")
    parse_fail("/.*/ stop_if_found /1/, /2/, 3")
    parse_fail("/.*/ stop_if_found /1/, /2/, /3")
    parse_fail("/.*/ stop_if_found /1/, /2/, /3/")
    parse_fail("%.*% stop_if_found /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! stop_if_found")
    parse_fail("/.*/ stop_if_found")
    parse_fail("/.*/ stop_if_found /")
    parse_fail("/.*/ stop_if_found //")
    parse_fail("/.*/ stop_if_found blah")
    parse_fail("/.*/ stop_if_found # bleep")
    parse_fail("/.*/ stop_if_found blah # bleep")

    # with invalid params
    parse_fail("/.*/ stop_if_found /")
    parse_fail("/.*/ stop_if_found //")
    parse_fail("/.*/ stop_if_found ///")
    parse_fail("/.*/ stop_if_found /*/")
    parse_fail("/.*/ stop_if_found /?/")
    parse_fail("/.*/ stop_if_found /+/")
    parse_fail("/.*/ stop_if_found /(/")
    parse_fail("/.*/ stop_if_found /(.*/")
    parse_fail("/.*/ stop_if_found /(.*))/")

    # with valid regexes
    parse_ok("%response_body% stop_if_found %<!--IGNORE_LOGGING-->%",
             "stop_if_found", "^response_body$", "<!--IGNORE_LOGGING-->", nil)
    parse_ok("/response_body/ stop_if_found /<!--IGNORE_LOGGING-->/",
             "stop_if_found", "^response_body$", "<!--IGNORE_LOGGING-->", nil)

    # with valid regexes and escape sequences
    parse_ok("!request_body|response_body! stop_if_found |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "stop_if_found", "^request_body|response_body$", "<!--IGNORE_LOGGING-->|<!-SKIP-->", nil)
    parse_ok("!request_body|response_body|boo\\!! stop_if_found |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "stop_if_found", "^request_body|response_body|boo!$", "<!--IGNORE_LOGGING-->|<!-SKIP-->", nil)
    parse_ok("|request_body\\|response_body| stop_if_found |<!--IGNORE_LOGGING-->\\|<!-SKIP-->|",
             "stop_if_found", "^request_body|response_body$", "<!--IGNORE_LOGGING-->|<!-SKIP-->", nil)
    parse_ok("/request_body\\/response_body/ stop_if_found |<!--IGNORE_LOGGING-->\\|<!-SKIP-->\\|pipe\\||",
             "stop_if_found", "^request_body/response_body$", "<!--IGNORE_LOGGING-->|<!-SKIP-->|pipe|", nil)
  end

  it 'parses stop_unless rules' do
    # with extra params
    parse_fail("|.*| stop_unless %1%, %2%")
    parse_fail("!.*! stop_unless /1/, 2")
    parse_fail("/.*/ stop_unless /1/, /2")
    parse_fail("/.*/ stop_unless /1/, /2/")
    parse_fail("/.*/ stop_unless /1/, /2/, /3/ # blah")
    parse_fail("!.*! stop_unless %1%, %2%, %3%")
    parse_fail("/.*/ stop_unless /1/, /2/, 3")
    parse_fail("/.*/ stop_unless /1/, /2/, /3")
    parse_fail("/.*/ stop_unless /1/, /2/, /3/")
    parse_fail("%.*% stop_unless /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! stop_unless")
    parse_fail("/.*/ stop_unless")
    parse_fail("/.*/ stop_unless /")
    parse_fail("/.*/ stop_unless //")
    parse_fail("/.*/ stop_unless blah")
    parse_fail("/.*/ stop_unless # bleep")
    parse_fail("/.*/ stop_unless blah # bleep")

    # with invalid params
    parse_fail("/.*/ stop_unless /")
    parse_fail("/.*/ stop_unless //")
    parse_fail("/.*/ stop_unless ///")
    parse_fail("/.*/ stop_unless /*/")
    parse_fail("/.*/ stop_unless /?/")
    parse_fail("/.*/ stop_unless /+/")
    parse_fail("/.*/ stop_unless /(/")
    parse_fail("/.*/ stop_unless /(.*/")
    parse_fail("/.*/ stop_unless /(.*))/")

    # with valid regexes
    parse_ok("%response_body% stop_unless %<!--DO_LOGGING-->%", "stop_unless", "^response_body$", "^<!--DO_LOGGING-->$", nil)
    parse_ok("/response_body/ stop_unless /<!--DO_LOGGING-->/", "stop_unless", "^response_body$", "^<!--DO_LOGGING-->$", nil)

    # with valid regexes and escape sequences
    parse_ok("!request_body|response_body! stop_unless |<!--DO_LOGGING-->\\|<!-NOSKIP-->|",
             "stop_unless", "^request_body|response_body$", "^<!--DO_LOGGING-->|<!-NOSKIP-->$", nil)
    parse_ok("!request_body|response_body|boo\\!! stop_unless |<!--DO_LOGGING-->\\|<!-NOSKIP-->|",
             "stop_unless", "^request_body|response_body|boo!$", "^<!--DO_LOGGING-->|<!-NOSKIP-->$", nil)
    parse_ok("|request_body\\|response_body| stop_unless |<!--DO_LOGGING-->\\|<!-NOSKIP-->|",
             "stop_unless", "^request_body|response_body$", "^<!--DO_LOGGING-->|<!-NOSKIP-->$", nil)
    parse_ok("|request_body\\|response_body| stop_unless |<!--DO_LOGGING-->\\|<!-NOSKIP-->\\|pipe\\||",
             "stop_unless", "^request_body|response_body$", "^<!--DO_LOGGING-->|<!-NOSKIP-->|pipe|$", nil)
    parse_ok("/request_body\\/response_body/ stop_unless |<!--DO_LOGGING-->\\|<!-NOSKIP-->\\|pipe\\||",
             "stop_unless", "^request_body/response_body$", "^<!--DO_LOGGING-->|<!-NOSKIP-->|pipe|$", nil)
  end

  it 'parses stop_unless_found rules' do
    # with extra params
    parse_fail("|.*| stop_unless_found %1%, %2%")
    parse_fail("!.*! stop_unless_found /1/, 2")
    parse_fail("/.*/ stop_unless_found /1/, /2")
    parse_fail("/.*/ stop_unless_found /1/, /2/")
    parse_fail("/.*/ stop_unless_found /1/, /2/, /3/ # blah")
    parse_fail("!.*! stop_unless_found %1%, %2%, %3%")
    parse_fail("/.*/ stop_unless_found /1/, /2/, 3")
    parse_fail("/.*/ stop_unless_found /1/, /2/, /3")
    parse_fail("/.*/ stop_unless_found /1/, /2/, /3/")
    parse_fail("%.*% stop_unless_found /1/, /2/, /3/ # blah")

    # with missing params
    parse_fail("!.*! stop_unless_found")
    parse_fail("/.*/ stop_unless_found")
    parse_fail("/.*/ stop_unless_found /")
    parse_fail("/.*/ stop_unless_found //")
    parse_fail("/.*/ stop_unless_found blah")
    parse_fail("/.*/ stop_unless_found # bleep")
    parse_fail("/.*/ stop_unless_found blah # bleep")

    # with invalid params
    parse_fail("/.*/ stop_unless_found /")
    parse_fail("/.*/ stop_unless_found //")
    parse_fail("/.*/ stop_unless_found ///")
    parse_fail("/.*/ stop_unless_found /*/")
    parse_fail("/.*/ stop_unless_found /?/")
    parse_fail("/.*/ stop_unless_found /+/")
    parse_fail("/.*/ stop_unless_found /(/")
    parse_fail("/.*/ stop_unless_found /(.*/")
    parse_fail("/.*/ stop_unless_found /(.*))/")

    # with valid regexes
    parse_ok("%response_body% stop_unless_found %<!--DO_LOGGING-->%",
             "stop_unless_found", "^response_body$", "<!--DO_LOGGING-->", nil)
    parse_ok("/response_body/ stop_unless_found /<!--DO_LOGGING-->/",
             "stop_unless_found", "^response_body$", "<!--DO_LOGGING-->", nil)

    # with valid regexes and escape sequences
    parse_ok("!request_body|response_body! stop_unless_found |<!--DO_LOGGING-->\\|<!-NOSKIP-->|",
             "stop_unless_found", "^request_body|response_body$", "<!--DO_LOGGING-->|<!-NOSKIP-->", nil)
    parse_ok("!request_body|response_body|boo\\!! stop_unless_found |<!--DO_LOGGING-->\\|<!-NOSKIP-->|",
             "stop_unless_found", "^request_body|response_body|boo!$", "<!--DO_LOGGING-->|<!-NOSKIP-->", nil)
    parse_ok("|request_body\\|response_body| stop_unless_found |<!--DO_LOGGING-->\\|<!-NOSKIP-->|",
             "stop_unless_found", "^request_body|response_body$", "<!--DO_LOGGING-->|<!-NOSKIP-->", nil)
    parse_ok("|request_body\\|response_body| stop_unless_found |<!--DO_LOGGING-->\\|<!-NOSKIP-->\\|pipe\\||",
             "stop_unless_found", "^request_body|response_body$", "<!--DO_LOGGING-->|<!-NOSKIP-->|pipe|", nil)
    parse_ok("/request_body\\/response_body/ stop_unless_found |<!--DO_LOGGING-->\\|<!-NOSKIP-->\\|pipe\\||",
             "stop_unless_found", "^request_body/response_body$", "<!--DO_LOGGING-->|<!-NOSKIP-->|pipe|", nil)
  end

  it 'raises expected errors' do
    begin
      HttpRules.parse("/*! stop")
      expect(false).to be true
    rescue RuntimeError => e
      expect(e.message).to eql("Invalid expression (/*!) in rule: /*! stop")
    end

    begin
      HttpRules.parse("/*/ stop")
      expect(false).to be true
    rescue RuntimeError => e
      expect(e.message).to eql("Invalid regex (/*/) in rule: /*/ stop")
    end

    begin
      HttpRules.parse("/boo")
      expect(false).to be true
    rescue RuntimeError => e
      expect(e.message).to eql("Invalid rule: /boo")
    end

    begin
      HttpRules.parse("sample 123")
      expect(false).to be true
    rescue RuntimeError => e
      expect(e.message).to eql("Invalid sample percent: 123")
    end

    begin
      HttpRules.parse("!!! stop")
      expect(false).to be true
    rescue RuntimeError => e
      expect(e.message).to eql("Unescaped separator (!) in rule: !!! stop")
    end
  end

end
