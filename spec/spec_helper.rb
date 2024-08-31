ENV['APP_ENV'] = 'test'

require 'minitest/autorun'
require 'capybara/minitest'
require 'rack/test'
require 'capybara/dsl'

require_relative '../app'  # Load your Rackup file

# Configure Capybara to use your Rack app
Capybara.app = Sinatra::Application.new

# Include Capybara DSL in Minitest
class Minitest::Spec
  include Capybara::DSL
  include Capybara::Minitest::Assertions
end

# Clean up after each test
class Minitest::AfterRun
  Minitest.after_run do
    Capybara.reset_sessions!
    Capybara.use_default_driver
    Posts.delete
    Feeds.delete
  end
end
