#!/bin/sh

# Wipe the DB and start afresh
bundle exec rake db:drop
bundle exec rake db:create

# Pull the data and schema from the production website through Taps
heroku db:pull --confirm staffplan

# Run whatever migration might be locally pending on that branch
bundle exec rake db:migrate

# Bring the test database up to speed
RAILS_ENV=test bundle exec rake db:migrate

# Run the tests
bundle exec rspec
