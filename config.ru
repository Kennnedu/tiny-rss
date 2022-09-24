require_relative 'app'
require 'scout_apm'

ScoutApm::Rack.install!

run Sinatra::Application
