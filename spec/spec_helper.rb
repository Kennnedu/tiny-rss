ENV['APP_ENV'] = 'test'

require 'minitest/autorun'
require 'capybara/minitest'
require 'rack/test'
require 'capybara/dsl'

require_relative '../tiny_rss'  # Load your Rackup file

# Configure Capybara to use your Rack app
Capybara.app = TinyRss.freeze.app

# Include Capybara DSL in Minitest
class Minitest::Spec
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  after do
    Posts.truncate
    Feeds.truncate
  end
end

# Clean up after each test
class Minitest::AfterRun
  Minitest.after_run do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
