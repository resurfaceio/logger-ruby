# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

class HttpRequestImpl

  def initialize
    @headers = Hash.new
    @raw_body = nil
  end

  def body
    @raw_body ? StringIO.new(@raw_body) : nil
  end

  def content_type
    @headers['Content-Type']
  end

  def content_type=(content_type)
    @headers['Content-Type'] = content_type
  end

  def headers
    @headers
  end

  attr_accessor :raw_body
  attr_accessor :request_method
  attr_accessor :url

end