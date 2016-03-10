# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/logger'

describe HttpLoggerFilter do

  it 'uses module namespace' do
    expect(HttpLoggerFilter.class.equal?(Resurfaceio::HttpLoggerFilter.class)).to be true
  end

  # todo missing test cases

end
