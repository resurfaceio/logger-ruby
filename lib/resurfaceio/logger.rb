# coding: utf-8
# Copyright (c) 2016 Resurface Labs LLC, All Rights Reserved

require 'uri'
require 'net/http'
require 'net/https'

module Resurfaceio
  class Logger

    DEFAULT_URL = 'https://resurfaceio.herokuapp.com/messages'

    def initialize(url = DEFAULT_URL)
      @url = url
      @version = Resurfaceio::Logger.version_lookup
    end

    def format_status(now)
      "{\"type\":\"status\",\"source\":\"resurfaceio-logger-ruby\",\"version\":\"#{version}\",\"now\":\"#{now}\"}"
    end

    def log_status
      post(format_status(Time.now.to_i)).eql?(200)
    end

    def post(body)
      begin
        uri = URI.parse(url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(uri.path)
        request.body = body
        response = https.request(request)
        response.code.to_i
      rescue SocketError
        404
      end
    end

    def url
      @url
    end

    def version
      @version
    end

    def self.version_lookup
      Gem.loaded_specs['resurfaceio-logger'].version.to_s
    end

  end
end
