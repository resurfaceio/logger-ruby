# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'

describe HttpLoggerForRails do

  it 'uses module namespace' do
    expect(HttpLoggerForRails.class.equal?(Resurfaceio::HttpLoggerForRails.class)).to be true
  end

  # todo missing test cases

end
