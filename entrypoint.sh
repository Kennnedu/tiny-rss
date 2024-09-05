#!/bin/bash
set -e

bundle install

whenever --update-crontab

service cron start

chromium --headless --no-sandbox --disable-gpu --remote-debugging-port=9222 --disable-dev-shm-usage & bundle exec rackup -p 3333 -o 0.0.0.0 -s puma
