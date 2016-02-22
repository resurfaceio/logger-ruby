# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'

describe JsonMessage do

  it 'uses module namespace' do
    expect(JsonMessage.class.equal?(Resurfaceio::JsonMessage.class)).to be true
  end

  it 'appends to message' do
    expect(JsonMessage.append('', 'name1', 123)).to eql("\"name1\":123")
    expect(JsonMessage.append('', '1name1', 1455908665227)).to eql("\"1name1\":1455908665227")
    expect(JsonMessage.append('', 'name2', 'value1')).to eql("\"name2\":\"value1\"")
    expect(JsonMessage.append('', 'sand_castle', "the cow says \"moo")).to eql("\"sand_castle\":\"the cow says \\\"moo\"")
    expect(JsonMessage.append('', 'Sand-Castle', "the cow says \"moo\"")).to eql("\"Sand-Castle\":\"the cow says \\\"moo\\\"\"")
  end

  it 'escapes strings for messages' do
    expect(JsonMessage.escape('', "\\the cow says moo")).to eql("\\\\the cow says moo")
    expect(JsonMessage.escape('', "the cow says moo\\")).to eql("the cow says moo\\\\")
    expect(JsonMessage.escape('', "the cow says \\moo")).to eql("the cow says \\\\moo")
    expect(JsonMessage.escape('', "\"the cow says moo")).to eql("\\\"the cow says moo")
    expect(JsonMessage.escape('', "the cow says moo\"")).to eql("the cow says moo\\\"")
    expect(JsonMessage.escape('', "the cow says \"moo")).to eql("the cow says \\\"moo")
  end

  it 'finishes a message' do
    expect(JsonMessage.finish('')).to eql('}')
  end

  it 'starts a message' do
    json = JsonMessage.start('', 'category1', 'source1', 'version1', 1455908589662)
    expect(json.include?("{\"category\":\"category1\",")).to be true
    expect(json.include?("\"source\":\"source1\",")).to be true
    expect(json.include?("\"version\":\"version1\",")).to be true
    expect(json.include?("\"now\":1455908589662")).to be true
  end

end
