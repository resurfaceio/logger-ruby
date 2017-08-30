# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'json'
require 'resurfaceio/base_logger'

class HttpLogger < BaseLogger

  AGENT = 'http_logger.rb'.freeze

  def initialize(options={})
    super(AGENT, options)
  end

  def format(request, request_body, response, response_body, now=Time.now.to_i.to_s)
    message = []
    append_value message, 'request_method', request.request_method
    append_value message, 'request_url', request.url
    append_value message, 'response_code', response.status
    append_request_headers message, request
    append_response_headers message, response
    append_value message, 'request_body', request_body.nil? ? request.body : request_body
    append_value message, 'response_body', response_body.nil? ? response.body : response_body
    message << ['agent', @agent]
    message << ['version', @version]
    message << ['now', now]
    JSON.generate message
  end

  def log(request, request_body, response, response_body)
    !enabled? || submit(format(request, request_body, response, response_body))
  end

  def string_content_type?(s)
    !s.nil? && s =~ /^(text\/(html|plain|xml))|(application\/(json|soap|xml|x-www-form-urlencoded))/i
  end

  protected

  def append_request_headers(message, request)
    respond_to_env = request.respond_to?(:env)
    if respond_to_env || request.respond_to?(:headers)
      headers = respond_to_env ? request.env : request.headers
      headers.each do |name, value|
        unless value.nil?
          if name =~ /^CONTENT_TYPE/
            message << ['request_header.content-type', value]
          end
          if name =~ /^HTTP_/
            message << ["request_header.#{name[5..-1].downcase.tr('_', '-')}", value]
          end
        end
      end
    end
  end

  def append_response_headers(message, response)
    found_content_type = false
    if response.respond_to?(:headers)
      response.headers.each do |name, value|
        unless value.nil?
          name = name.downcase
          found_content_type = true if name =~ /^content-type/
          message << ["response_header.#{name}", value]
        end
      end
    end
    unless found_content_type || response.content_type.nil?
      message << ['response_header.content-type', response.content_type]
    end
  end

  def append_value(message, key, value=nil)
    unless key.nil?
      unless value.nil?
        case value
          when Array
            message << [key, value.join]
          when String
            message << [key, value]
          else
            if value.respond_to?(:read)
              message << [key, value.read]
            else
              message << [key, value.to_s]
            end
        end
      end
    end
    message
  end

end
