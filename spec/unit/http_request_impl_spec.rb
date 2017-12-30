# coding: utf-8
# © 2016-2018 Resurface Labs LLC

require 'resurfaceio/all'
require_relative 'helper'

describe HttpRequestImpl do

  it 'uses content_type' do
    r = HttpRequestImpl.new
    expect(r.content_type).to be nil
    expect(r.headers['CONTENT_TYPE']).to be nil

    val = 'application/whatever'
    r.content_type = val
    expect(r.content_type).to eql(val)
    expect(r.headers['CONTENT_TYPE']).to eql(val)
    expect(r.headers['content_type']).to be nil

    r.content_type = nil
    expect(r.content_type).to be nil
    expect(r.headers['CONTENT_TYPE']).to be nil
    expect(r.headers['content_type']).to be nil
  end

  it 'uses form hash' do
    key = '2345'
    key2 = 'egret'
    val = 'u-turn'
    val2 = 'bleep'

    r = HttpRequestImpl.new
    expect(r.form_hash.length).to be 0
    expect(r.form_hash[key]).to be nil

    r.form_hash[key] = val
    expect(r.form_hash.length).to be 1
    expect(r.form_hash[key]).to eql(val)

    r.form_hash[key] = val2
    expect(r.form_hash.length).to be 1
    expect(r.form_hash[key]).to eql(val2)

    r.form_hash[key2] = val2
    expect(r.form_hash.length).to be 2
    expect(r.form_hash[key2]).to eql(val2)
    expect(r.form_hash[key2.upcase]).to be nil
  end

  it 'uses headers' do
    key = '3456'
    key2 = 'freddy'
    val = 'two-step'
    val2 = 'swell!'

    r = HttpRequestImpl.new
    expect(r.headers.length).to be 0
    expect(r.headers[key]).to be nil

    r.headers[key] = val
    expect(r.headers.length).to be 1
    expect(r.headers[key]).to eql(val)

    r.headers[key] = val2
    expect(r.headers.length).to be 1
    expect(r.headers[key]).to eql(val2)

    r.add_header(key, val)
    expect(r.headers.length).to be 1
    expect(r.headers[key]).to eql("#{val2}, #{val}")

    r.headers[key2] = val2
    expect(r.headers.length).to be 2
    expect(r.headers[key2]).to eql(val2)
    expect(r.headers[key2.upcase]).to be nil
  end

  it 'uses query hash' do
    key = '4567'
    key2 = 'gracious'
    val = 'forever-more'
    val2 = 'carson'

    r = HttpRequestImpl.new
    expect(r.query_hash.length).to be 0
    expect(r.query_hash[key]).to be nil

    r.query_hash[key] = val
    expect(r.query_hash.length).to be 1
    expect(r.query_hash[key]).to eql(val)

    r.query_hash[key] = val2
    expect(r.query_hash.length).to be 1
    expect(r.query_hash[key]).to eql(val2)

    r.query_hash[key2] = val2
    expect(r.query_hash.length).to be 2
    expect(r.query_hash[key2]).to eql(val2)
    expect(r.query_hash[key2.upcase]).to be nil
  end

  it 'uses request method' do
    val = '!METHOD!'
    r = HttpRequestImpl.new
    expect(r.request_method).to be nil
    r.request_method = val
    expect(r.request_method).to eql(val)
  end

  it 'uses url' do
    val = 'http://goofball.com'
    r = HttpRequestImpl.new
    expect(r.url).to be nil
    r.url = val
    expect(r.url).to eql(val)
  end

end
