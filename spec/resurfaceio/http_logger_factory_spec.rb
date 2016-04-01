# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'

describe HttpLoggerFactory do

  it 'uses module namespace' do
    expect(HttpLoggerFactory.class.equal?(Resurfaceio::HttpLoggerFactory.class)).to be true
    expect(Resurfaceio::HttpLoggerFactory.get).to eql(HttpLoggerFactory.get)
  end

  it 'uses default logger' do
    expect(HttpLoggerFactory.get.equal?(HttpLoggerFactory.get)).to be true
    HttpLoggerFactory.get.disable
    expect(HttpLoggerFactory.get.enabled?).to be false
    HttpLoggerFactory.get.enable
    expect(HttpLoggerFactory.get.enabled?).to be true
  end

end
