# resurfaceio-logger-ruby
&copy; 2016 Resurface Labs LLC, All Rights Reserved

This gem makes it easy to log server usage including HTTP request/response details.

## Dependencies

No runtime dependencies to conflict with your app. Requires Ruby 2.x.

## Installing with Bundler

Add this line to your Gemfile:

    gem 'resurfaceio-logger', :git => 'https://github.com/resurfaceio/resurfaceio-logger-ruby.git'

## Using Rails Controller

Add an around_action to log use of one specific controller:

    require 'resurfaceio/logger'

    class MyController < ApplicationController
      around_action HttpLoggerForRails.new
    end

## Using Rack Middleware

Add to config.ru to log all usage of the app:

    require 'resurfaceio/logger'
    use HttpLoggerForRack

## Using API

    require 'resurfaceio/logger'

    logger = HttpLoggerFactory.get       # returns default cached HTTP logger
    logger.log_request(request)          # log HTTP request details
    logger.log_response(response)        # log HTTP response details
    if logger.enabled? ...               # intending to log stuff?
    logger.enable                        # enable logging for dev/staging/production
    logger.disable                       # disable logging for automated tests
