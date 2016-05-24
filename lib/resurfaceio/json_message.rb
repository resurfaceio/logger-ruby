# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

class JsonMessage

  def self.append(json, key, value=nil)
    json << "\""
    json << key.to_s
    json << "\""
    unless value.nil?
      json << ':'
      case value
        when Array
          json << "\""
          JsonMessage.escape(json, value.join)
          json << "\""
        when String
          json << "\""
          JsonMessage.escape(json, value)
          json << "\""
        else
          if value.respond_to?(:read)
            json << "\""
            JsonMessage.escape(json, value.read)
            json << "\""
          else
            json << value.to_s
          end
      end
    end
    json
  end

  def self.append_headers(json, headers)
    first = true
    headers.each do |name, value|
      if name =~ /^CONTENT_TYPE/
        append(json << (first ? '{' : ',{'), 'content-type', value) << '}'
        first = false
      end
      if name =~ /^HTTP_/
        append(json << (first ? '{' : ',{'), name[5..-1].downcase.tr('_', '-'), value) << '}'
        first = false
      end
    end
    json
  end

  def self.escape(json, value)
    value.to_s.each_char do |c|
      case c
        when '"'
          json << "\\\""
        when '\\'
          json << "\\\\"
        when "\b"
          json << "\\b"
        when "\f"
          json << "\\f"
        when "\n"
          json << "\\n"
        when "\r"
          json << "\\r"
        when "\t"
          json << "\\t"
        else
          json << c
      end
    end
    json
  end

  def self.start(json, category, agent, version, now)
    json << "{\"category\":\""
    json << category
    json << "\",\"agent\":\""
    json << agent
    json << "\",\"version\":\""
    json << version
    json << "\",\"now\":"
    json << now.to_s
    json
  end

  def self.stop(json)
    json << '}'
    json
  end

end