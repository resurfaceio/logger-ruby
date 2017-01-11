# resurfaceio-logger-ruby
&copy; 2016-2017 Resurface Labs LLC

## Coding Conventions

Our code style is whatever RubyMine does by default, with the exception of allowing lines up to 130 characters.
If you don't use RubyMine, that's ok, but your code may get reformatted.

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