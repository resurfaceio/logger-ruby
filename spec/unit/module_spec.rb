# coding: utf-8
# © 2016-2018 Resurface Labs LLC

require 'resurfaceio/all'

describe Resurfaceio do

  it 'uses module namespace' do
    expect(BaseLogger.class.equal?(Resurfaceio::BaseLogger.class)).to be true
    expect(Resurfaceio::BaseLogger.version_lookup).to eql(BaseLogger.version_lookup)
    expect(HttpLogger.class.equal?(Resurfaceio::HttpLogger.class)).to be true
    expect(Resurfaceio::HttpLogger.version_lookup).to eql(HttpLogger.version_lookup)
    expect(HttpLoggerForRack.class.equal?(Resurfaceio::HttpLoggerForRack.class)).to be true
    expect(HttpLoggerForRails.class.equal?(Resurfaceio::HttpLoggerForRails.class)).to be true
    expect(HttpMessageImpl.class.equal?(Resurfaceio::HttpMessageImpl.class)).to be true
    expect(HttpRequestImpl.class.equal?(Resurfaceio::HttpRequestImpl.class)).to be true
    expect(HttpResponseImpl.class.equal?(Resurfaceio::HttpResponseImpl.class)).to be true
    expect(UsageLoggers.class.equal?(Resurfaceio::UsageLoggers.class)).to be true
  end

end
