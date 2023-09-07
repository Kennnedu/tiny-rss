# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#

env 'GEM_HOME', '/usr/local/bundle'
env 'DATABASE_URL', ENV['DATABASE_URL']

set :output, "/app/log/cron_log.log"

every 1.minute do
  rake "fetch_feeds"
end

#every 10.minutes do
#  rake "clear_feeds"
#end

every :day do
  command 'cp -rf /app/db/*.sqlite3 /app/tmp/'
end

# Learn more: http://github.com/javan/whenever
