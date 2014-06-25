require 'spec_helper'
require 'capybara/rspec'
require 'rspec/core/rake_task'

require_relative '../config/application.rb'

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
  config.color_enabled = true
  config.formatter = :documentation
  config.order = 'random'
end

# This is for checking to see that each endpoint page has the correct information on it
Capybara.configure do |config|
  config.app = Rack::Builder.parse_file('config.ru').first
  config.server_port = 9293
end