# resurfaceio-logger-ruby
&copy; 2016-2017 Resurface Labs LLC

This gem makes it easy to log actual usage of Ruby web/json apps.

## Contents

<ul>
<li><a href="#dependencies">Dependencies</a></li>
<li><a href="#installing_with_bundler">Installing With Bundler</a></li>
<li><a href="#logging_from_rails_controller">Logging From Rails Controller</a></li>
<li><a href="#logging_from_rack_middleware">Logging From Rack Middleware</a></li>
<li><a href="#logging_from_sinatra">Logging From Sinatra</a></li>
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

After <a href="#installing_with_bundler">installing the gem</a>, add an around_action to any Rails controller as
shown below.

    require 'resurfaceio/all'                                        # add at top of file

    class MyController < ApplicationController
      around_action HttpLoggerForRails.new(url: 'DEMO')              # add inside controller
    end

With this configuration, usage data will be logged to our 
[free demo environment](https://demo-resurfaceio.herokuapp.com/messages), but you can alternatively
<a href="#logging_to_different_urls">log to any URL</a>.

<a name="logging_from_rack_middleware"/>

## Logging From Rack Middleware

This logs usage of apps on Sinatra and other Rack-based frameworks, including Rails. Unlike the example for Rails
above, this requires no changes to your controllers, and logs response headers that are not seen by Rails controllers.

After <a href="#installing_with_bundler">installing the gem</a>, add these lines below to config.ru, before the final
'run' statement.

    require 'resurfaceio/all'                                        # add this line
    use HttpLoggerForRack, url: 'DEMO'                               # add this line
    run <...>

With this configuration, usage data will be logged to our 
[free demo environment](https://demo-resurfaceio.herokuapp.com/messages), but you can alternatively
<a href="#logging_to_different_urls">log to any URL</a>.

<a name="logging_from_sinatra"/>

## Logging From Sinatra

<a href="#logging_from_rack_middleware">Logging from rack middleware</a> works for Sinatra applications, assuming the need is to
log all usage. Otherwise a logger can be used just for specific routes only. (In Sinatra, a route is a URL-matching pattern
associated with a block of code)

After <a href="#installing_with_bundler">installing the gem</a>, create a logger and use it from the routes of interest.

    require 'sinatra'
    require 'resurfaceio/all'

    logger = HttpLogger.new(url: 'DEMO')

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

With this configuration, usage data will be logged to our 
[free demo environment](https://demo-resurfaceio.herokuapp.com/messages), but you can alternatively
<a href="#logging_to_different_urls">log to any URL</a>.

<a name="logging_to_different_urls"/>

## Logging To Different URLs

Our loggers don't lock you into using any particular backend service. Loggers can send data to any URL that accepts JSON
messages as a standard HTTP/HTTPS POST. A single application can use multiple loggers configured with different URLs.

    # for basic logger
    logger = HttpLogger.new(url: 'https://my-https-url')

    # for rack middleware
    use HttpLoggerForRack, url: 'https://my-https-url'

    # for rails controller
    around_action HttpLoggerForRails.new(url: 'https://my-other-url?session-token')

<a name="advanced_topics"/>

## Advanced Topics

<a name="setting_default_url"/>

### Setting Default URL

Set the USAGE_LOGGERS_URL environment variable to provide a default value whenever the URL is not specified.

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
    logger.log(request, nil, response, nil)

    # log with overriden request/response bodies
    logger.log(request, 'my-request', response, 'my-response')

    # submit a custom message (destination may accept or not)
    logger.submit('...')
