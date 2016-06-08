# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/all'
require_relative 'helper'

describe HttpResponseImpl do

  it 'uses module namespace' do
    expect(HttpResponseImpl.class.equal?(Resurfaceio::HttpResponseImpl.class)).to be true
  end

  it 'uses body' do
    val = 'Conway Stern'
    r = HttpResponseImpl.new
    expect(r.body).to be nil
    r.raw_body = val
    expect(r.body.class.name).to eql('Array')
    expect(r.body.join).to eql(val)
  end

  it 'uses content_type' do
    val = 'application/whatever'
    r = HttpResponseImpl.new
    expect(r.content_type).to be nil
    r.content_type = val
    expect(r.content_type).to eql(val)
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
    r.headers[key2] = val2
    expect(r.headers.length).to be 2
    expect(r.headers[key2]).to eql(val2)
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
