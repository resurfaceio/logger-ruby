# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/all'
require_relative 'helper'

describe JsonMessage do

  it 'detects good json' do
    expect(parseable?('{}')).to be true
    expect(parseable?('{ }')).to be true
    expect(parseable?("{\n}")).to be true
    expect(parseable?("{\n\n\n}")).to be true
    expect(parseable?(MOCK_JSON)).to be true
  end

  it 'detects invalid json' do
    expect(parseable?(nil)).to be false
    expect(parseable?('')).to be false
    expect(parseable?(' ')).to be false
    expect(parseable?("\n\n\n\n")).to be false
    expect(parseable?('1234')).to be false
    expect(parseable?('archer')).to be false
    expect(parseable?("\"sterling archer\"")).to be false
    expect(parseable?('[]')).to be true
    expect(parseable?('[,]')).to be false
    expect(parseable?('[:,]')).to be false
    expect(parseable?('[ ]')).to be true
    expect(parseable?(',')).to be false
    expect(parseable?('{')).to be false
    expect(parseable?('{,')).to be false
    expect(parseable?(',,')).to be false
    expect(parseable?('{{')).to be false
    expect(parseable?('{{,,')).to be false
    expect(parseable?('}')).to be false
    expect(parseable?(',}')).to be false
    expect(parseable?('},')).to be false
    expect(parseable?(',},')).to be false
    expect(parseable?('{{}')).to be false
    expect(parseable?('{,}')).to be false
    expect(parseable?('{,,}')).to be false
    expect(parseable?('exact words')).to be false
    expect(parseable?('his exact words')).to be false
    expect(parseable?("\"exact words")).to be false
    expect(parseable?("his exact words\"")).to be false
    expect(parseable?("\"hello\":\"world\" }")).to be false
    expect(parseable?("{ \"hello\":\"world\"")).to be false
    expect(parseable?("{ \"hello world\"}")).to be false
    expect(parseable?("{ \"hello\" world\"}")).to be false
    expect(parseable?("{ \"hello \"world\"}")).to be false
    expect(parseable?("{ \"hello world\":}")).to be false
    expect(parseable?("{ \"hello\"\"world\" }")).to be false
    expect(parseable?("{ \"hello\"\"world\", }")).to be false
    expect(parseable?("{ ,\"hello\"\"world\" }")).to be false
    expect(parseable?("{ ,\"hello\"\"world\", }")).to be false
    expect(parseable?("{ \"hello\":\"world\"\"hello\":\"world\" }")).to be false
    expect(parseable?("{ ,\"hello\":\"world\"\"hello\":\"world\" }")).to be false
    expect(parseable?("{ \"hello\":\"world\"\"hello\":\"world\", }")).to be false
    expect(parseable?("{ [ \"hello\":\"world\" }")).to be false
    expect(parseable?("{ [ \"hello\":\"world\",] }")).to be false
    expect(parseable?("{ [ \"hello\":\"world\" ], }")).to be false
    expect(parseable?("{ [ \"hello\":\"world\" ] \"hello\":\"world\" }")).to be false
    expect(parseable?(MOCK_JSON_ESCAPED)).to be false
    expect(parseable?(MOCK_HTML)).to be false
    expect(parseable?(MOCK_HTML_ESCAPED)).to be false
  end

end