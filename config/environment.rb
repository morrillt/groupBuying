require "rubygems"
require "bundler"
Bundler.setup

require 'sinatra'
require 'active_record'
require 'logger'

# require 'erb'
# require 'fastercsv'
# require 'ostruct'
# require 'active_record'
# require 'mysql2'
require 'active_support/core_ext/float/rounding'

environment = Sinatra::Application.environment.to_s || "test"
dbconfig = YAML.load(File.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection dbconfig[environment]

Dir['{lib,models}/*.rb'].each { |filename| require filename }

require 'init'