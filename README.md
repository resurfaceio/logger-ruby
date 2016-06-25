# resurfaceio-logger-ruby
&copy; 2016 Resurface Labs LLC, All Rights Reserved

This gem makes it easy to log usage of Rails/Rack apps, including HTTP request/response details.

Contents
--------

<ul>
<li><a href="#dependencies">Dependencies</a></li>
<li><a href="#installing_with_bundler">Installing With Bundler</a></li>
<li><a href="#logging_from_rails_controller">Logging From Rails Controller</a></li>
<li><a href="#logging_from_rack_middleware">Logging From Rack Middleware</a></li>
<li><a href="#logging_to_different_urls">Logging To Different URLs</a></li>
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

    gem 'resurfaceio-logger', :git => 'https://github.com/resurfaceio/resurfaceio-logger-ruby.git'

Then update using Bundler:

    bundle install

<a name="logging_from_rails_controller"/>

## Logging From Rails Controller

Rails is the most popular Ruby framework, and is featured by Heroku's
[Getting Started with Ruby](https://devcenter.heroku.com/articles/getting-started-with-ruby) tutorial.
(If you've never used Rails or Heroku before, this tutorial is a great walkthrough)

After <a href="#installing_with_bundler">installing the logger gem</a>, add an around_action to any Rails controller as
shown below.

    require 'resurfaceio/all'                                  # add at top of file

    class MyController < ApplicationController
      around_action HttpLoggerForRails.new(url: 'DEMO')        # add inside controller
    end

Usage data will now be logged here:
[https://demo-resurfaceio.herokuapp.com/messages](https://demo-resurfaceio.herokuapp.com/messages)

*Resurface Labs provides this free demo environment just to make our stuff easy to try. Data sent to this demo
environment is held in volatile memory for less than 24 hours, and is never shared with third parties.
(<a href="">Privacy and Terms of Service</a>)*

<a name="logging_from_rack_middleware"/>

## Logging From Rack Middleware

This logs usage of apps on Sinatra and other Rack-based frameworks, including Rails. Unlike the example for Rails
above, this requires no changes to your controllers, and logs response headers that are not seen by Rails controllers.

This logger performs some basic filtering: it ignores redirects (304 response codes), and only logs responses for content
types matching a predefined list (including 'text/html' and 'application/json').

After <a href="#installing_with_bundler">installing the logger gem</a>, add these lines below to config.ru, before the final
'run' statement.

    require 'resurfaceio/all'                   # add this line
    use HttpLoggerForRack, url: 'DEMO'          # add this line
    run <...>                                   # this was already there, no changes

Usage data will now be logged here:
[https://demo-resurfaceio.herokuapp.com/messages](https://demo-resurfaceio.herokuapp.com/messages)

*Resurface Labs provides this free demo environment just to make our stuff easy to try. Data sent to this demo
environment is held in volatile memory for less than 24 hours, and is never shared with third parties.
(<a href="">Privacy and Terms of Service</a>)*

<a name="logging_to_different_urls"/>

## Logging To Different URLs

Our loggers don't lock you into using any particular backend service. Loggers can send data to any URL that accepts JSON
messages as a standard HTTPS POST.

    # for rack middleware
    use HttpLoggerForRack, url: 'https://my-url-1'

    # for rails controller
    around_action HttpLoggerForRails.new(url: 'https://my-url-2?session-token')

    # for another rails controller
    around_action HttpLoggerForRails.new(url: 'https://my-url-3')

As shown in the fake example above, an app can have separate loggers that send usage data to different URLs at once.

<a name="advanced_topics"/>

## Advanced Topics

<a name="setting_default_url"/>

### Setting Default URL

Set the USAGE_LOGGER_URL variable to provide a default value whenever the URL is not specified. This is most useful when you
intend to have multiple loggers using a single backend service.

    # using Heroku cli
    heroku config:set USAGE_LOGGER_URL=https://my-destination-url

    # from within config.ru or rails configuration file
    ENV['USAGE_LOGGER_URL']='https://my-destination-url'

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
    heroku config:set USAGE_LOGGER_DISABLED=true

    # from within Rails config
    ENV['USAGE_LOGGER_DISABLED']='true'

    # at runtime
    UsageLoggers.disable

<a name="using_api_directly"/>

### Using API Directly

Loggers can be directly integrated into your application if Rails/Rack instrumentation don't fit. This requires the most effort,
but yields complete control over what details are logged, and where the data is sent.

    require 'resurfaceio/all'

    # create and manage logger
    logger = HttpLogger.new(queue: my_queue)                     # log to appendable list
    logger = HttpLogger.new(queue: my_queue, enabled: false)     # (initially disabled)
    logger = HttpLogger.new(url: my_https_url)                   # custom destination
    logger = HttpLogger.new(url: my_https_url, enabled: false)   # (initially disabled)
    logger.disable                                               # disable this logger
    logger.enable                                                # enable this logger
    if logger.enabled? ...                                       # test if this enabled

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
    logger.log(request, nil, response, nil)

    # log with overriden request/response bodies
    logger.log(request, 'my-request', response, 'my-response')

    # submit a custom message (destination may accept or not)
    logger.submit('...')
