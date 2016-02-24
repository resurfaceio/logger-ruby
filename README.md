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

## Using with Rails

### Logging requests and responses

    class WelcomeController < ApplicationController
      around_action HttpLoggerFilter.new
    end

### Logging requests only

    class WelcomeController < ApplicationController
      before_action HttpLoggerFilter.new
    end

### Logging responses only

    class WelcomeController < ApplicationController
      after_action HttpLoggerFilter.new
    end

### Custom around_action

    class WelcomeController < ApplicationController
      around_action :custom_around_action
      def custom_around_action
        logger = HttpLoggerFactory.get
        logger.log_request(request)
        begin
          yield
        ensure
          logger.log_response(response)
        end
      end
    end
