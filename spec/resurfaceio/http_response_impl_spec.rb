# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'
require_relative 'mocks'

describe HttpResponseImpl do

  it 'uses module namespace' do
    expect(HttpResponseImpl.class.equal?(Resurfaceio::HttpResponseImpl.class)).to be true
  end

  it 'uses body' do
    r = HttpResponseImpl.new
    expect(r.body).to be nil
    r.body = MOCK_HTML
    expect(r.body).to eql(MOCK_HTML)
  end

  it 'uses content_type' do
    val = 'application/whatever'
    r = HttpResponseImpl.new
    expect(r.content_type).to be nil
    r.content_type = val
    expect(r.content_type).to eql(val)
  end

  it 'uses status' do
    val = 123
    r = HttpResponseImpl.new
    expect(r.status).to be nil
    r.status = val
    expect(r.status).to eql(val)
  end

end
