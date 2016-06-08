# resurfaceio-logger-ruby
&copy; 2016 Resurface Labs LLC, All Rights Reserved

This gem makes it easy to log server usage including HTTP request/response details.

## Dependencies

Requires Ruby 2.x. No other dependencies to conflict with your app.

## Installing With Bundler

Add this line to your Gemfile:

    gem 'resurfaceio-logger', :git => 'https://github.com/resurfaceio/resurfaceio-logger-ruby.git'

Then update using Bundler:

    bundle install

## Logging From Rails Controller

Rails is the most popular Ruby framework, and is nicely introduced by the
[Getting Started on Heroku with Ruby](https://devcenter.heroku.com/articles/getting-started-with-ruby) tutorial.

Configure an around_action as shown below to log from any Rails controller. This can be applied selectively
(just one or two controllers) or done in a superclass to apply logging across many controllers.

    require 'resurfaceio/all'

    class MyController < ApplicationController
      around_action HttpLoggerForRails.new
    end

## Logging From Rack Middleware

This works for Sinatra and other Rack-based frameworks including Rails. This requires no changes to your app
except for tweaking Rack middleware like the example below.

    # config.ru
    # This file is used by Rack-based servers to start the application.
    require ::File.expand_path('../config/environment',  __FILE__)
    require 'resurfaceio/all'      # added!
    use HttpLoggerForRack          # added!
    run Rails.application

HttpLoggerForRack performs some basic filtering: it ignores redirects (304 response codes), and only logs responses
for content types matching a predefined list (including 'text/html' and 'application/json').

## Using API Directly

    require 'resurfaceio/all'

    # manage default logger
    logger = HttpLoggerFactory.get              # returns cached HTTP logger
    logger.disable                              # disable logging for automated tests
    logger.enable                               # re-enable logging after being disabled
    if logger.enabled? ...                      # branch on logging being enabled

    # log a HTTP exchange
    req = HttpRequestImpl.new                   # define request to log
    req.url = 'http://google.com'
    res = HttpResponseImpl.new                  # define response to log
    res.content_type('text/html')
    res.status = 200
    logger.log_request(req)                     # log the request  (use body if present)
    logger.log_request(req, body)               # log the request  (with specified body)
    logger.log_response(res)                    # log the response (use body if present)
    logger.log_response(res, body)              # log the response (with specified body)
