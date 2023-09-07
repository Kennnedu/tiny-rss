#!/bin/bash
set -e

bundle install

whenever --update-crontab

service cron start

bundle exec rackup -p 3333 -o 0.0.0.0 -s puma
