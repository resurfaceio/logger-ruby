# resurfaceio-logger-ruby
&copy; 2016-2017 Resurface Labs LLC

This gem makes it easy to log actual usage of Ruby web/json apps.

[![Gem Version](https://badge.fury.io/rb/resurfaceio-logger.svg)](https://badge.fury.io/rb/resurfaceio-logger)

## Contents

<ul>
<li><a href="#dependencies">Dependencies</a></li>
<li><a href="#installing_with_bundler">Installing With Bundler</a></li>
<li><a href="#logging_from_rails_controller">Logging From Rails Controller</a></li>
<li><a href="#logging_from_rack_middleware">Logging From Rack Middleware</a></li>
<li><a href="#logging_from_sinatra">Logging From Sinatra</a></li>
<li><a href="#advanced_topics">Advanced Topics</a><ul>
<li><a href="#setting_default_url">Setting Default URL</a></li>
<li><a href="#disabling_all_logging">Disabling All Logging</a></li>
<li><a href="#using_api_directly">Using API Directly</a></li>
</ul></li>
</ul>

<a name="dependencies"/>

## Dependencies

Requires Ruby 2.x. No other dependencies to conflict with your app.

<a name="installing_with_bundler"/>

## Installing With Bundler

Add this line to your Gemfile:

    gem 'resurfaceio-logger'

Then install using Bundler: `bundle install`

<a name="logging_from_rails_controller"/>

## Logging From Rails Controller

After <a href="#installing_with_bundler">installing the gem</a>, add an `around_action` to your Rails controller.

    require 'resurfaceio/all'

    class MyController < ApplicationController
      around_action HttpLoggerForRails.new(url: 'https://...')
    end


<a name="logging_from_rack_middleware"/>

## Logging From Rack Middleware

After <a href="#installing_with_bundler">installing the gem</a>, add these lines below to `config.ru`, before the final
'run' statement.

    require 'resurfaceio/all'
    use HttpLoggerForRack, url: 'https://...'
    run <...>

<a name="logging_from_sinatra"/>

## Logging From Sinatra

After <a href="#installing_with_bundler">installing the gem</a>, create a logger and use it from the routes of interest.

    require 'sinatra'
    require 'resurfaceio/all'

    logger = HttpLogger.new(url: 'https://...')

    get '/' do
      response_body = '<html>Hello World</html>'
      logger.log request, nil, response, response_body
      response_body
    end

    post '/' do
      status 401
      logger.log request, nil, response, nil
      ''
    end

<a name="advanced_topics"/>

## Advanced Topics

<a name="setting_default_url"/>

### Setting Default URL

Set the `USAGE_LOGGERS_URL` environment variable to provide a default value whenever the URL is not specified.

    # using Heroku cli
    heroku config:set USAGE_LOGGERS_URL=https://my-https-url

    # from within config.ru or rails configuration file
    ENV['USAGE_LOGGERS_URL']='https://my-https-url'

Loggers look for this environment variable when no other options are set, as in these examples.

    # in rails context
    around_action HttpLoggerForRails.new

    # in rack context
    use HttpLoggerForRack

    # using api directly
    HttpLogger.new

<a name="disabling_all_logging"/>

### Disabling All Logging

It's important to have a "kill switch" to universally disable all logging. For example, loggers might be disabled when
running automated tests. All loggers can also be disabled at runtime, either by setting an environment variable or
programmatically.

    # for Heroku app
    heroku config:set USAGE_LOGGERS_DISABLE=true

    # from within Rails config
    ENV['USAGE_LOGGERS_DISABLE']='true'

    # at runtime
    UsageLoggers.disable

<a name="using_api_directly"/>

### Using API Directly

Loggers can be directly integrated into your application if other options don't fit. This requires the most effort, but
yields complete control over how usage logging is implemented.

    require 'resurfaceio/all'
    
    # manage all loggers (even those not created yet)
    UsageLoggers.disable                                             # disable all loggers
    UsageLoggers.enable                                              # enable all loggers
    
    # create and configure logger
    logger = HttpLogger.new(queue: my_queue)                         # log to appendable list
    logger = HttpLogger.new(queue: my_queue, enabled: false)         # (initially disabled)
    logger = HttpLogger.new(url: my_https_url)                       # log to https url
    logger = HttpLogger.new(url: my_https_url, enabled: false)       # (initially disabled)
    logger.disable                                                   # disable this logger
    logger.enable                                                    # enable this logger
    if logger.enabled? ...                                           # test if this enabled
    
    # define request to log
    request = HttpRequestImpl.new
    request.body = 'some json'
    request.content_type = 'application/json'
    request.headers['A'] = '123'
    request.request_method = 'GET'
    request.url = 'http://google.com'
    
    # define response to log
    response = HttpResponseImpl.new
    response.body = 'some html'
    response.content_type = 'text/html'
    response.headers['B'] = '234'
    response.status = 200
    
    # log objects defined above
    logger.log request, nil, response, nil
    
    # log with overriden request/response bodies
    logger.log request, 'my-request', response, 'my-response'
    
    # submit a custom message (destination may accept or not)
    logger.submit '...'
