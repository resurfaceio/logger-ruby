# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'resurfaceio/all'
require_relative 'helper'

describe HttpRequestImpl do

  it 'uses module namespace' do
    expect(HttpRequestImpl.class.equal?(Resurfaceio::HttpRequestImpl.class)).to be true
  end

  it 'uses body' do
    val = 'Sterling Archer'
    r = HttpRequestImpl.new
    expect(r.body).to be nil
    r.raw_body = val
    expect(r.body.class.name).to eql('StringIO')
    expect(r.body.read).to eql(val)
  end

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

  it 'uses headers' do
    key = '2345'
    key2 = 'fish'
    val = 'u-turn'
    val2 = 'swell'

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

  it 'uses raw_body' do
    r = HttpRequestImpl.new
    expect(r.raw_body).to be nil
    r.raw_body = MOCK_HTML
    expect(r.raw_body).to eql(MOCK_HTML)
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
