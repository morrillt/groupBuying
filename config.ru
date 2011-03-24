# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
# run Groupster::Application

require 'resque/server'

# Set the AUTH env variable to your basic auth password to protect Resque.
AUTH_PASSWORD = 'blancaj5'
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD 
  end
end


run Rack::URLMap.new \
   "/" => Groupster::Application,
   "/resque" => Resque::Server.new