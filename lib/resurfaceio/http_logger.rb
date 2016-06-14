# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/base_logger'
require 'resurfaceio/json_message'

class HttpLogger < BaseLogger

  AGENT = 'http_logger.rb'

  def initialize(url = DEFAULT_URL, enabled = true)
    super(AGENT, url, enabled)
  end

  def append_to_buffer(json, now, request, request_body, response, response_body)
    JsonMessage.start(json, 'http', agent, version, now)
    JsonMessage.append(json << ',', 'request_method', request.request_method)
    JsonMessage.append(json << ',', 'request_url', request.url)
    append_request_headers(json << ',', request)
    unless request_body.nil? && request.body.nil?
      JsonMessage.append(json << ',', 'request_body', request_body.nil? ? request.body : request_body)
    end
    JsonMessage.append(json << ',', 'response_code', response.status)
    append_response_headers(json << ',', response)
    unless response_body.nil? && response.body.nil?
      JsonMessage.append(json << ',', 'response_body', response_body.nil? ? response.body : response_body)
    end
    JsonMessage.stop(json)
  end

  def format(request, request_body, response, response_body)
    append_to_buffer(String.new, Time.now.to_i, request, request_body, response, response_body)
  end

  def log(request, request_body, response, response_body)
    !active? || submit(format(request, request_body, response, response_body))
  end

  protected

  def append_request_headers(json, request)
    JsonMessage.append(json, 'request_headers') << ':['
    first = true
    respond_to_env = request.respond_to?(:env)
    if respond_to_env || request.respond_to?(:headers)
      headers = respond_to_env ? request.env : request.headers
      headers.each do |name, value|
        if name =~ /^CONTENT_TYPE/
          JsonMessage.append(json << (first ? '{' : ',{'), 'content-type', value) << '}'
          first = false
        end
        if name =~ /^HTTP_/
          JsonMessage.append(json << (first ? '{' : ',{'), name[5..-1].downcase.tr('_', '-'), value) << '}'
          first = false
        end
      end
    end
    json << ']'
  end

  def append_response_headers(json, response)
    JsonMessage.append(json, 'response_headers') << ':['
    first = true
    found_content_type = false
    if response.respond_to?(:headers)
      response.headers.each do |name, value|
        name = name.downcase
        found_content_type = true if name =~ /^content\-type/
        JsonMessage.append(json << (first ? '{' : ',{'), name, value) << '}'
        first = false
      end
    end
    unless found_content_type || response.content_type.nil?
      JsonMessage.append(json << (first ? '{' : ',{'), 'content-type', response.content_type) << '}'
    end
    json << ']'
  end

end
