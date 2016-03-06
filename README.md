# resurfaceio-logger-ruby
&copy; 2016 Resurface Labs LLC, All Rights Reserved

This gem makes it easy to log server usage including HTTP request/response details.

## Dependencies

No runtime dependencies to conflict with your app. Requires Ruby 2.x.

## Installing with Bundler

Add this line to your Gemfile:

    gem 'resurfaceio-logger', :git => 'https://github.com/resurfaceio/resurfaceio-logger-ruby.git'

## Ruby API

    require 'resurfaceio/logger'

    logger = HttpLoggerFactory.get       # returns default cached HTTP logger
    logger.log_request(request)          # log HTTP request details
    logger.log_response(response)        # log HTTP response details
    if logger.is_enabled? ...            # intending to log stuff?
    logger.enable                        # enable logging for dev/staging/production
    logger.disable                       # disable logging for automated tests

## Using Rails

To enable logging for a controller, configure an action as shown here:

    class MyController < ApplicationController

      # log all requests/responses to this controller
      around_action HttpLoggerFilter.new

    end
