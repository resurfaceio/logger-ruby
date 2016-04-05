# resurfaceio-logger-ruby
&copy; 2016 Resurface Labs LLC, All Rights Reserved

This gem makes it easy to log server usage including HTTP request/response details.

## Dependencies

No runtime dependencies to conflict with your app. Requires Ruby 2.x.

## Installing with Bundler

Add this line to your Gemfile:

    gem 'resurfaceio-logger', :git => 'https://github.com/resurfaceio/resurfaceio-logger-ruby.git'

## Using Rails Controller

Configure an around_action as shown below to log from any Rails controller. This can be applied selectively (just one or two controllers) or done in a superclass to
apply logging across multiple controllers simultaneously.

    require 'resurfaceio/logger'

    class MyController < ApplicationController
      around_action HttpLoggerForRails.new
    end

## Using Rack Middleware

This works for Sinatra and other Rack-based frameworks including Rails. This does usage logging without changing application controllers to use around_actions.
Simply add a top-level use method as shown below. (For rails, this is config.ru)

    require 'resurfaceio/logger'
    use HttpLoggerForRack

The Rack logger performs some basic filtering: it ignores redirects (304 response codes), and only logs responses for content types matching a predefined list
(including 'text/html' and 'application/json').

## Using API Directly

    require 'resurfaceio/logger'

    logger = HttpLoggerFactory.get       # returns default cached HTTP logger
    logger.log_request(request)          # log HTTP request details
    logger.log_response(response)        # log HTTP response details
    if logger.enabled? ...               # intending to log stuff?
    logger.enable                        # enable logging for dev/staging/production
    logger.disable                       # disable logging for automated tests
