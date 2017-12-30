# coding: utf-8
# © 2016-2018 Resurface Labs LLC

require 'json'
require 'resurfaceio/all'
require_relative 'helper'

describe JSON do

  it 'detects good json' do
    expect(parseable?('[]')).to be true
    expect(parseable?('[ ]')).to be true
    expect(parseable?("[\n]")).to be true
    expect(parseable?("[\n\t\n]")).to be true
    expect(parseable?("[\"A\"]")).to be true
    expect(parseable?("[\"A\",\"B\"]")).to be true
  end

  it 'detects invalid json' do
    expect(parseable?(nil)).to be false
    expect(parseable?('')).to be false
    expect(parseable?(' ')).to be false
    expect(parseable?("\n\n\n\n")).to be false
    expect(parseable?('1234')).to be false
    expect(parseable?('archer')).to be false
    expect(parseable?('\"sterling archer\"')).to be false
    expect(parseable?("[\"]")).to be false
    expect(parseable?('[:,]')).to be false
    expect(parseable?(',')).to be false
    expect(parseable?('exact words')).to be false
    expect(parseable?('his exact words')).to be false
    expect(parseable?('\"exact words')).to be false
    expect(parseable?('his exact words\"')).to be false
    expect(parseable?('\"hello\":\"world\" }')).to be false
    expect(parseable?('{ \"hello\":\"world\"')).to be false
    expect(parseable?('{ \"hello world\"}')).to be false
  end

end