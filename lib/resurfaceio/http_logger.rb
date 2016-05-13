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
    JsonMessage.append(json, 'url', request.url)
    unless body.nil? && request.body.nil?
      json << ','
      JsonMessage.append(json, 'body', body.nil? ? request.body.read : body)
    end
    JsonMessage.stop(json)
  end

  def format_response(json, now, response, body=nil)
    JsonMessage.start(json, 'http_response', agent, version, now) << ','
    JsonMessage.append(json, 'code', response.status)
    unless body.nil? && response.body.nil?
      json << ','
      JsonMessage.append(json, 'body', body.nil? ? response.body.join : body)
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
