# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

class JsonMessage

  def self.append(json, key, value=nil)
    unless key.nil?
      json << "\"" << key.to_s << "\""
      unless value.nil?
        json << ":\""
        case value
          when Array
            JsonMessage.escape(json, value.join)
          when String
            JsonMessage.escape(json, value)
          else
            if value.respond_to?(:read)
              JsonMessage.escape(json, value.read)
            else
              json << value.to_s
            end
        end
        json << "\""
      end
    end
    json
  end

  def self.escape(json, value)
    unless value.nil?
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
    end
    json
  end

  def self.start(json, category, agent, version, now)
    json << "{\"category\":\"" << category
    json << "\",\"agent\":\"" << agent
    json << "\",\"version\":\"" << version
    json << "\",\"now\":\"" << now.to_s << "\""
    json
  end

  def self.stop(json)
    json << '}'
    json
  end

end