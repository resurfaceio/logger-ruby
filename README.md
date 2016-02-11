# resurfaceio-logger-ruby
&copy; 2016 Resurface Labs LLC, All Rights Reserved

## Installing

Add this line to your Gemfile:

    gem 'resurfaceio-logger', :git => 'https://github.com/resurfaceio/resurfaceio-logger-ruby.git'

## Git Workflow

    git clone git@github.com:resurfaceio/resurfaceio-logger-ruby.git ~/resurfaceio-logger-ruby
    cd ~/resurfaceio-logger-ruby
    git pull
    (make changes)
    bundle exec rspec                         (run automated tests)
    git status                                (review changes)
    git add -A
    git commit -m "#123 Updated readme"       (123 is the GitHub issue number)
    git pull
    git push origin master

    # when we're ready to push through public repos
    gem build resurfaceio-logger.gemspec