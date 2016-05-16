# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'
require_relative 'mocks'

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
    val = 'application/whatever'
    r = HttpRequestImpl.new
    expect(r.content_type).to be nil
    r.content_type = val
    expect(r.content_type).to eql(val)
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
