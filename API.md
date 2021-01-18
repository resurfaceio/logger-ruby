# API

## Contents

<ul>
<li><a href="#creating_loggers">Creating Loggers</a></li>
<li><a href="#logging_http">Logging HTTP Calls</a></li>
<li><a href="#setting_default_rules">Setting Default Rules</a></li>
<li><a href="#setting_default_url">Setting Default URL</a></li>
<li><a href="#enabling_and_disabling_loggers">Enabling and Disabling Loggers</a></li>
</ul>

<a name="creating_loggers"/>

## Creating Loggers

To get started, first you'll need to create a `HttpLogger` instance. Here there are options to specify a URL (for where JSON 
messages will be sent) and/or a specific set of <a href="https://resurface.io/rules.html">logging rules</a> (for what privacy 
protections to apply). Default values will be used for either of these if specific values are not provided.

```ruby
require 'resurfaceio/all'

# with default url and rules
logger = HttpLogger.new

# with specific url and default rules
logger = HttpLogger.new(url: 'https://...')

# with specific url and rules
logger = HttpLogger.new(url: 'https://...', rules: 'include strict')

# with specific url and rules from local file
logger = HttpLogger.new(url: 'https://...', rules: 'file://./rules.txt')
```

<a name="logging_http"/>

## Logging HTTP Calls

Now that you have a logger instance, let's do some logging. Here you can pass standard request/response objects, as well
as response body and request body content when these are available. 

```ruby
# with standard objects
HttpMessage.send(logger, request, response)

# with response body
HttpMessage.send(logger, request, response, 'my-response-body')

# with response and request body
HttpMessage.send(logger, request, response, 'my-response-body', 'my-request-body')
```

If standard request and response objects aren't available in your case, create mock implementations to pass instead.

```ruby
# define request to log
request = HttpRequestImpl.new
request.body = 'some json'
request.content_type = 'application/json'
request.headers['A'] = '123'
request.request_method = 'POST'
request.form_hash['B'] = '234'  # POST param
request.url = 'http://resurface.io'

# define response to log
response = HttpResponseImpl.new
response.body = 'some html'
response.content_type = 'text/html; charset=utf-8'
response.headers['B'] = '234'
response.status = 200

# log objects defined above
HttpMessage.send(logger, request, response)
```

<a name="setting_default_rules"/>

## Setting Default Rules

If no <a href="https://resurface.io/rules.html">rules</a> are provided when creating a logger, the default value of 
`include strict` will be applied. A different default value can be specified as shown below.

```ruby
HttpRules.default_rules = 'include debug'
```

When specifying multiple default rules, put each on a separate line. This is most easily done with a non-interpolated string.

```ruby
HttpRules.default_rules = %q(
  include debug
  sample 10
)
```

<a name="setting_default_url"/>

## Setting Default URL

If your application creates more than one logger, or requires different URLs for different environments (development vs
testing vs production), then set the `USAGE_LOGGERS_URL` environment variable. This value will be applied if no other URL
is specified when creating a logger.

```ruby
# in config.ru
ENV['USAGE_LOGGERS_URL']='https://...'

# from command line
export USAGE_LOGGERS_URL="https://..."

# for Heroku app
heroku config:set USAGE_LOGGERS_URL=https://...
```

<a name="enabling_and_disabling_loggers"/>

## Enabling and Disabling Loggers

Individual loggers can be controlled through their `enable` and `disable` methods. When disabled, loggers will
not send any logging data, and the result returned by the `log` method will always be true (success).

All loggers for an application can be enabled or disabled at once with the `UsageLoggers` class. This even controls
loggers that have not yet been created by the application.

```ruby
UsageLoggers.disable       # disable all loggers
UsageLoggers.enable        # enable all loggers
```

All loggers can be permanently disabled with the `USAGE_LOGGERS_DISABLE` environment variable. When set to true,
loggers will never become enabled, even if `UsageLoggers.enable` is called by the application. This is primarily 
done by automated tests to disable all logging even if other control logic exists. 

```ruby
# in config.ru
ENV['USAGE_LOGGERS_DISABLE']='true'

# from command line
export USAGE_LOGGERS_DISABLE="true"

# for Heroku app
heroku config:set USAGE_LOGGERS_DISABLE=true
```

---
<small>&copy; 2016-2021 <a href="https://resurface.io">Resurface Labs Inc.</a></small>
