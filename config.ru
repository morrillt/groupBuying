# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
# run Groupster::Application

require 'resque/server'

# Set the AUTH env variable to your basic auth password to protect Resque.
# Resque::Server.use Rack::Auth::Basic do |username, password|
#   username == 'admin'
#   password == 'GBin2011' 
# end

run Rack::URLMap.new \
   "/" => Groupster::Application,
   "/resque" => Resque::Server.new