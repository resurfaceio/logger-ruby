# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/base_logger'
require 'resurfaceio/json_message'

class HttpLogger < BaseLogger

  AGENT = 'http_logger.rb'

  def agent
    AGENT
  end

  def format_echo(json, now)
    JsonMessage.start(json, 'echo', agent, version, now)
    JsonMessage.stop(json)
  end

  def format_request(json, now, request, body=nil)
    JsonMessage.start(json, 'http_request', agent, version, now) << ','
    JsonMessage.append(json, 'method', request.request_method) << ','
    JsonMessage.append(json, 'url', request.url) << ','
    append_request_headers(json, request)
    JsonMessage.append(json << ',', 'body', body.nil? ? request.body : body) unless body.nil? && request.body.nil?
    JsonMessage.stop(json)
  end

  def format_response(json, now, response, body=nil)
    JsonMessage.start(json, 'http_response', agent, version, now) << ','
    JsonMessage.append(json, 'code', response.status) << ','
    append_response_headers(json, response)
    JsonMessage.append(json << ',', 'body', body.nil? ? response.body : body) unless body.nil? && response.body.nil?
    JsonMessage.stop(json)
  end

  def log_echo
    if active?
      post format_echo(String.new, Time.now.to_i)
    else
      true
    end
  end

  def log_request(request, body=nil)
    if active?
      post format_request(String.new, Time.now.to_i, request, body)
    else
      true
    end
  end

  def log_response(response, body=nil)
    if active?
      post format_response(String.new, Time.now.to_i, response, body)
    else
      true
    end
  end

  protected

  def append_request_headers(json, request)
    JsonMessage.append(json, 'headers') << ':['
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
    JsonMessage.append(json, 'headers') << ':['
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
