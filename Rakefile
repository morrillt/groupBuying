# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

# Resque with Hoptoad
require 'resque/failure/hoptoad'
Resque::Failure::Hoptoad.configure do |config|
  config.api_key = '96eed5dfaa5dad1350dfb5283724dd0d'
end

Groupster::Application.load_tasks