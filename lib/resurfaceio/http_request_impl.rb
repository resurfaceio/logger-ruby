# coding: utf-8
# © 2016-2017 Resurface Labs LLC

class HttpRequestImpl

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
    @raw_body ? StringIO.new(@raw_body) : nil
  end

  def content_type
    @headers['CONTENT_TYPE']
  end

  def content_type=(content_type)
    @headers['CONTENT_TYPE'] = content_type
  end

  def headers
    @headers
  end

  attr_accessor :raw_body
  attr_accessor :request_method
  attr_accessor :url

end