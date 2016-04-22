# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'resurfaceio/json_message'
require 'resurfaceio/usage_logger'

class HttpLogger < UsageLogger

  def format_echo(json, now)
    JsonMessage.start(json, 'echo', SOURCE, version, now)
    JsonMessage.finish(json)
  end

  def format_request(json, now, request)
    JsonMessage.start(json, 'http_request', SOURCE, version, now) << ','
    JsonMessage.append(json, 'url', request.url)
    JsonMessage.finish(json)
  end

  def format_response(json, now, response, body=nil)
    JsonMessage.start(json, 'http_response', SOURCE, version, now) << ','
    JsonMessage.append(json, 'code', response.status)
    unless body.nil? && response.body.nil?
      json << ','
      JsonMessage.append(json, 'body', body.nil? ? response.body : body)
    end
    JsonMessage.finish(json)
  end

  def log_echo
    if @enabled || @tracing
      json = format_echo(String.new, Time.now.to_i)
      post(json).eql?(200)
    else
      true
    end
  end

  def log_request(request)
    if @enabled || @tracing
      json = format_request(String.new, Time.now.to_i, request)
      post(json).eql?(200)
    else
      true
    end
  end

  def log_response(response, body=nil)
    if @enabled || @tracing
      json = format_response(String.new, Time.now.to_i, response, body)
      post(json).eql?(200)
    else
      true
    end
  end

end
