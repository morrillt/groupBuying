ENV["RAILS_ENV"] ||= 'test'

require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
Bundler.require 'rspec/rails'

require 'factory_girl'

# Include any factories that might be in the spec dir.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'**','*.rb'))].each {|f| require f}

Rspec.configure do |config|
  config.mock_with :rspec
end
