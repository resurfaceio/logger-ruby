# coding: utf-8
# © 2016-2022 Resurface Labs Inc.

class HttpRequestImpl

  def initialize
    @form_hash = Hash.new
    @headers = Hash.new
    @query_hash = Hash.new
    @session = Hash.new
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

  def content_type
    @headers['CONTENT_TYPE']
  end

  def content_type=(content_type)
    @headers['CONTENT_TYPE'] = content_type
  end

  def form_hash
    @form_hash
  end

  def headers
    @headers
  end

  def query_hash
    @query_hash
  end

  def session
    @session
  end

  attr_accessor :request_method
  attr_accessor :url

end