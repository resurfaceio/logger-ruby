# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'spec_helper'

describe Resurfaceio::Logger do

  it 'formats status' do
    status = Resurfaceio::Logger.new.format_status(1234)
    expect(status).to be_kind_of String
    expect(status).not_to be nil
    expect(status.length).to be > 0
    expect(status.include?("\"type\":\"status\"")).to be true
    expect(status.include?("\"source\":\"resurfaceio-logger-ruby\"")).to be true
    expect(status.include?("\"version\":\"" + Resurfaceio::Logger.version_lookup + "\"")).to be true
    expect(status.include?("\"now\":\"1234\"")).to be true
  end

  it 'logs status' do
    expect(Resurfaceio::Logger.new.log_status).to be true
    expect(Resurfaceio::Logger.new("#{Resurfaceio::Logger::DEFAULT_URL}/noway3is5this1valid2").log_status).to be false
    expect(Resurfaceio::Logger.new('https://www.noway3is5this1valid2.com/').log_status).to be false
    expect(Resurfaceio::Logger.new('http://www.noway3is5this1valid2.com/').log_status).to be false
  end

  it 'uses url' do
    url = Resurfaceio::Logger::DEFAULT_URL
    expect(url).to be_kind_of String
    expect(url).not_to be nil
    expect(url.length).to be > 0
    expect(url.start_with?('https://')).to be true
    expect(url.include?('\\')).to be false
    expect(url.include?('\"')).to be false
    expect(url.include?('\'')).to be false
    expect(Resurfaceio::Logger.new.url).to eql(Resurfaceio::Logger::DEFAULT_URL)
    expect(Resurfaceio::Logger.new('https://foobar.com').url).to eql('https://foobar.com')
  end

  it 'uses version' do
    version = Resurfaceio::Logger.version_lookup
    expect(version).to be_kind_of String
    expect(version).not_to be nil
    expect(version.length).to be > 0
    expect(version.start_with?('1.0')).to be true
    expect(version.include?('\\')).to be false
    expect(version.include?('\"')).to be false
    expect(version.include?('\'')).to be false
    expect(Resurfaceio::Logger.new.version).to eql(Resurfaceio::Logger.version_lookup)
  end

end
