# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'

describe JsonMessage do

  it 'uses module namespace' do
    expect(JsonMessage.class.equal?(Resurfaceio::JsonMessage.class)).to be true
  end

  it 'appends arrays to message' do
    expect(JsonMessage.append('', 'a', %w(b))).to eql("\"a\":\"b\"")
    expect(JsonMessage.append('', 'b', [1])).to eql("\"b\":\"1\"")
    expect(JsonMessage.append('', 'c', ["can\"t"])).to eql("\"c\":\"can\\\"t\"")
    expect(JsonMessage.append('X', 'd', %w(a b solute))).to eql("X\"d\":\"absolute\"")
  end

  it 'appends numbers to message' do
    expect(JsonMessage.append('', 'name', -1)).to eql("\"name\":-1")
    expect(JsonMessage.append('', 'name1', 123)).to eql("\"name1\":123")
    expect(JsonMessage.append('{', '1name1', 1455908665227)).to eql("{\"1name1\":1455908665227")
  end

  it 'appends objects to message' do
    expect(JsonMessage.append('', 'io', StringIO.new('as'))).to eql("\"io\":\"as\"")
    expect(JsonMessage.append('', 'io', StringIO.new('as if'))).to eql("\"io\":\"as if\"")
    expect(JsonMessage.append('!', 'io', StringIO.new("as\"if"))).to eql("!\"io\":\"as\\\"if\"")
  end

  it 'appends strings to message' do
    expect(JsonMessage.append('', 'A', '')).to eql("\"A\":\"\"")
    expect(JsonMessage.append('', 'B', ' ')).to eql("\"B\":\" \"")
    expect(JsonMessage.append('', 'C', '   ')).to eql("\"C\":\"   \"")
    expect(JsonMessage.append('', 'D', "\t")).to eql("\"D\":\"\\t\"")
    expect(JsonMessage.append('', 'E', "\t\t ")).to eql("\"E\":\"\\t\\t \"")
    expect(JsonMessage.append('{', 'name2', 'value1')).to eql("{\"name2\":\"value1\"")
    expect(JsonMessage.append('', 'b_2', "the cow says \"moo")).to eql("\"b_2\":\"the cow says \\\"moo\"")
    expect(JsonMessage.append('', 's-c-2', "the cow says \"moo\"")).to eql("\"s-c-2\":\"the cow says \\\"moo\\\"\"")
  end

  it 'escapes backslashes' do
    expect(JsonMessage.escape('!', "\\the cow says moo")).to eql("!\\\\the cow says moo")
    expect(JsonMessage.escape('', "the cow says moo\\")).to eql("the cow says moo\\\\")
    expect(JsonMessage.escape('', "the cow says \\moo")).to eql("the cow says \\\\moo")
  end

  it 'escapes backspaces' do
    expect(JsonMessage.escape('{', "\bthe cow says moo")).to eql("{\\bthe cow says moo")
    expect(JsonMessage.escape('', "the cow says moo\b")).to eql("the cow says moo\\b")
    expect(JsonMessage.escape('', "the cow says \bmoo")).to eql("the cow says \\bmoo")
  end

  it 'escapes form feeds' do
    expect(JsonMessage.escape('', "\fthe cow says moo")).to eql("\\fthe cow says moo")
    expect(JsonMessage.escape('', "the cow says moo\f")).to eql("the cow says moo\\f")
    expect(JsonMessage.escape('', "the cow says \fmoo")).to eql("the cow says \\fmoo")
  end

  it 'escapes new lines' do
    expect(JsonMessage.escape('', "\nthe cow says moo")).to eql("\\nthe cow says moo")
    expect(JsonMessage.escape('', "the cow says moo\n")).to eql("the cow says moo\\n")
    expect(JsonMessage.escape('', "the cow says \nmoo")).to eql("the cow says \\nmoo")
  end

  it 'escapes quotes' do
    expect(JsonMessage.escape('', "\"the cow says moo")).to eql("\\\"the cow says moo")
    expect(JsonMessage.escape('', "the cow says moo\"")).to eql("the cow says moo\\\"")
    expect(JsonMessage.escape('', "the cow says \"moo")).to eql("the cow says \\\"moo")
  end

  it 'escapes returns' do
    expect(JsonMessage.escape('', "\rthe cow says moo")).to eql("\\rthe cow says moo")
    expect(JsonMessage.escape('', "the cow says moo\r")).to eql("the cow says moo\\r")
    expect(JsonMessage.escape('', "the cow says \rmoo")).to eql("the cow says \\rmoo")
  end

  it 'escapes tabs' do
    expect(JsonMessage.escape('', "\tthe cow says moo")).to eql("\\tthe cow says moo")
    expect(JsonMessage.escape('', "the cow says moo\t")).to eql("the cow says moo\\t")
    expect(JsonMessage.escape('', "the cow says \tmoo")).to eql("the cow says \\tmoo")
  end

  it 'starts a message' do
    json = JsonMessage.start('', 'category1', 'agent1', 'version1', 1455908589662)
    expect(json.include?("{\"category\":\"category1\",")).to be true
    expect(json.include?("\"agent\":\"agent1\",")).to be true
    expect(json.include?("\"version\":\"version1\",")).to be true
    expect(json.include?("\"now\":1455908589662")).to be true
  end

  it 'stops a message' do
    expect(JsonMessage.stop('')).to eql('}')
  end

end
