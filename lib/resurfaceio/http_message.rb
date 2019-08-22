# coding: utf-8
# © 2016-2019 Resurface Labs Inc.

require 'json'

class HttpMessage

  def self.build(request, response, response_body = nil, request_body = nil)
    message = []
    append_value message, 'request_method', request.request_method unless request.request_method.nil?
    append_value message, 'request_url', request.url unless request.url.nil?
    append_value message, 'response_code', response.status unless response.status.nil?
    append_request_headers message, request
    append_request_params message, request
    append_response_headers message, response
    append_value message, 'request_body', request_body unless request_body == ''
    final_response_body = response_body.nil? ? response.body : response_body
    append_value message, 'response_body', final_response_body unless final_response_body == ''
    return message
  end

  protected

  def self.append_request_headers(message, request)
    respond_to_env = request.respond_to?(:env)
    if respond_to_env || request.respond_to?(:headers)
      headers = respond_to_env ? request.env : request.headers
      headers.each do |name, value|
        unless value.nil?
          if name =~ /^CONTENT_TYPE/
            message << ['request_header:content-type', value]
          end
          if name =~ /^HTTP_/
            message << ["request_header:#{name[5..-1].downcase.tr('_', '-')}", value]
          end
        end
      end unless headers.nil?
    end
  end

  def self.append_request_params(message, request)
    respond_to_env = request.respond_to?(:env)
    if respond_to_env || request.respond_to?(:form_hash)
      hash = respond_to_env ? request.env['rack.request.form_hash'] : request.form_hash
      hash.each do |name, value|
        append_value message, "request_param:#{name.downcase}", value
      end unless hash.nil?
    end
    if respond_to_env || request.respond_to?(:query_hash)
      hash = respond_to_env ? request.env['rack.request.query_hash'] : request.query_hash
      hash.each do |name, value|
        append_value message, "request_param:#{name.downcase}", value
      end unless hash.nil?
    end
  end

  def self.append_response_headers(message, response)
    found_content_type = false
    if response.respond_to?(:headers)
      response.headers.each do |name, value|
        unless value.nil?
          name = name.downcase
          found_content_type = true if name =~ /^content-type/
          message << ["response_header:#{name}", value]
        end
      end unless response.headers.nil?
    end
    unless found_content_type || response.content_type.nil?
      message << ['response_header:content-type', response.content_type]
    end
  end

  def self.append_value(message, key, value = nil)
    unless key.nil?
      unless value.nil?
        case value
          when Array
            message << [key, value.join]
          when String
            message << [key, value]
          else
            message << [key, value.to_s]
        end
      end
    end
    message
  end

end
