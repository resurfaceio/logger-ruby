# coding: utf-8
# © 2016-2023 Resurface Labs Inc.

class HttpResponseImpl

  def initialize
    @headers = Hash.new
    @raw_body = nil
  end

  def add_header(key, value)
    unless value.nil?
      existing = @headers[key]
      if existing.nil?
        @headers[key] = value
      else
        @headers[key] = "#{existing}, #{value}"
      end
    end
  end

  def body
    @raw_body ? [@raw_body] : nil
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
  attr_accessor :status

end