# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

require 'resurfaceio/all'
require_relative 'helper'

describe HttpResponseImpl do

  it 'uses body' do
    val = 'Conway Stern'
    r = HttpResponseImpl.new
    expect(r.body).to be nil
    r.raw_body = val
    expect(r.body.class.name).to eql('Array')
    expect(r.body.join).to eql(val)
  end

  it 'uses content_type' do
    r = HttpResponseImpl.new
    expect(r.content_type).to be nil
    expect(r.headers['Content-Type']).to be nil

    val = 'application/whatever'
    r.content_type = val
    expect(r.content_type).to eql(val)
    expect(r.headers['Content-Type']).to eql(val)
    expect(r.headers['CONTENT-TYPE']).to be nil

    r.content_type = nil
    expect(r.content_type).to be nil
    expect(r.headers['Content-Type']).to be nil
    expect(r.headers['CONTENT-TYPE']).to be nil
  end

  it 'uses headers' do
    key = '2345789'
    key2 = 'jane fred'
    val = 'bob'
    val2 = 'swoosh'

    r = HttpResponseImpl.new
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

  it 'uses raw body' do
    r = HttpResponseImpl.new
    expect(r.raw_body).to be nil
    r.raw_body = MOCK_HTML
    expect(r.raw_body).to eql(MOCK_HTML)
  end

  it 'uses status' do
    val = 123
    r = HttpResponseImpl.new
    expect(r.status).to be nil
    r.status = val
    expect(r.status).to eql(val)
  end

end
