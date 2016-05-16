# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

class HttpRequestImpl

  def body
    @raw_body ? StringIO.new(@raw_body) : nil
  end

  attr_accessor :content_type
  attr_accessor :raw_body
  attr_accessor :request_method
  attr_accessor :url

end