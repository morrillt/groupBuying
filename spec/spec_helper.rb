require File.join(File.dirname(__FILE__), '..', 'charts.rb')

require 'rubygems'
require 'sinatra'
require 'rspec'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
