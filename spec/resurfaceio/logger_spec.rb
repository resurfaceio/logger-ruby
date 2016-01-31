# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'spec_helper'

describe Resurfaceio::Logger do
  it 'has version number' do
    version = Resurfaceio::Logger.version
    expect(version).to be_kind_of String
    expect(version).not_to be nil
    expect(version.length).to be > 0
    expect(version.start_with?('1.0')).to be true
  end
end
