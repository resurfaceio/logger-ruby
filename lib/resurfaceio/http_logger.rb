# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'json'
require 'resurfaceio/base_logger'
require 'resurfaceio/http_message_impl'

class HttpLogger < BaseLogger

  AGENT = 'http_logger.rb'.freeze

  def self.string_content_type?(s)
    !s.nil? && !(s =~ /^(text\/(html|plain|xml))|(application\/(json|soap|xml|x-www-form-urlencoded))/i).nil?
  end

  def initialize(options = {})
    super(AGENT, options)
  end

  def format(request, response, response_body = nil, request_body = nil, now = nil)
    message = HttpMessageImpl.build(request, response, response_body, request_body)
    message << ['agent', @agent]
    message << ['version', @version]
    message << ['now', now.nil? ? (Time.now.to_f * 1000).floor.to_s : now]
    JSON.generate message
  end

  def log(request, response, response_body = nil, request_body = nil)
    !enabled? || submit(format(request, response, response_body, request_body))
  end

end
