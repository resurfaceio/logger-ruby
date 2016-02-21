# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

class JsonMessage

  def self.append(json, key, value)
    json << "\""
    json << key.to_s
    json << "\":"
    case value
      when String
        json << "\""
        JsonMessage.escape(json, value)
        json << "\""
      else
        json << value.to_s
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
        else
          json << c
      end
    end
    json
  end

  def self.finish(json)
    json << '}'
    json
  end

  def self.start(json, category, source, version, now)
    json << "{\"category\":\""
    json << category
    json << "\",\"source\":\""
    json << source
    json << "\",\"version\":\""
    json << version
    json << "\",\"now\":"
    json << now.to_s
    json
  end

end