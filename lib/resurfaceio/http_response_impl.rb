# coding: utf-8
# © 2016-2017 Resurface Labs LLC

class HttpResponseImpl

  def initialize
    @headers = Hash.new
    @raw_body = nil
  end

  def add_header(key, value)
    unless value.nil?
      if @headers.has_key?(key)
        @headers[key] = "#{@headers[key]},#{value}"
      else
        @headers[key] = value
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