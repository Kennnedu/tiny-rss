#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
#rails assets:clean

whenever --update-crontab

service cron start

bundle exec rackup -p 3333 -o 0.0.0.0 -s puma
# Then exec the container's main process (what's set as CMD in the Dockerfile).

