# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'

describe HttpLoggerForRack do

  it 'uses module namespace' do
    expect(HttpLoggerForRack.class.equal?(Resurfaceio::HttpLoggerForRack.class)).to be true
  end

  # todo missing test cases

end
