require 'sinatra'
require 'rspec'
# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

RSpec.configure do |config|
  config.mock_with :rspec
end

require File.join(File.dirname(__FILE__), '..', 'charts.rb')

# stubbing this way since rspec-mocks don't seem to be working.
class Date
  def self.today
    Date.new(2011, 3, 1)
  end

  def self.yesterday
    Date.new(2011, 2, 28)
  end
end
