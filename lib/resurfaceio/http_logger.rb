# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/json_message'
require 'resurfaceio/usage_logger'

class HttpLogger < UsageLogger

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

    # add headers to json
    JsonMessage.append(json, 'headers') << ':['
    respond_to_env = request.respond_to?(:env)
    respond_to_headers = request.respond_to?(:headers)
    if respond_to_env || respond_to_headers
      first = true
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

    # add body to json
    unless body.nil? && request.body.nil?
      json << ','
      JsonMessage.append(json, 'body', body.nil? ? request.body : body)
    end
    JsonMessage.stop(json)
  end

  def format_response(json, now, response, body=nil)
    JsonMessage.start(json, 'http_response', agent, version, now) << ','
    JsonMessage.append(json, 'code', response.status) << ','

    # add headers to json
    first = true
    found_content_type = false
    JsonMessage.append(json, 'headers') << ':['
    if response.respond_to?(:headers)
      response.headers.each do |name, value|
        name = name.downcase
        found_content_type = true if name =~ /^content\-type/
        JsonMessage.append(json << (first ? '{' : ',{'), name, value) << '}'
        first = false
      end
    end
    unless found_content_type || response.content_type.nil?
      # for whatever reason, content_type is present but isn't reflected by headers
      JsonMessage.append(json << (first ? '{' : ',{'), 'content-type-MISSINGHEADER', response.content_type) << '}'
    end
    json << ']'

    # add body to json
    unless body.nil? && response.body.nil?
      json << ','
      JsonMessage.append(json, 'body', body.nil? ? response.body : body)
    end
    JsonMessage.stop(json)
  end

  def log_echo
    if @enabled || @tracing
      post format_echo(String.new, Time.now.to_i)
    else
      true
    end
  end

  def log_request(request, body=nil)
    if @enabled || @tracing
      post format_request(String.new, Time.now.to_i, request, body)
    else
      true
    end
  end

  def log_response(response, body=nil)
    if @enabled || @tracing
      post format_response(String.new, Time.now.to_i, response, body)
    else
      true
    end
  end

end
