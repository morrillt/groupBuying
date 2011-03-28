# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'shoulda'
require 'factory_girl'
require 'resque_spec'
require 'json'

Factory.definition_file_paths = [ File.join(Rails.root, 'spec', 'factories') ]

if (!Factory.factories || Factory.factories.empty?)
  Dir.glob(File.dirname(__FILE__) + "/factories/*.rb").each do |factory|
    require factory
  end
end

#require Rails.root.join("spec/factories/factories.rb")

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end

