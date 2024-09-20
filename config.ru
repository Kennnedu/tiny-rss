require_relative 'app'
require 'htmlcompressor'

use HtmlCompressor::Rack

run Sinatra::Application
