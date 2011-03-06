require "rubygems"
require "bundler"
Bundler.setup

require 'active_support/all'
require 'sinatra'
require 'active_record'
require 'logger'
require 'meta_where'

environment = Sinatra::Application.environment.to_s || "test"
dbconfig = YAML.load(File.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection dbconfig[environment]

Dir['{lib,models}/*.rb'].each { |filename| require filename }
set :root, File.join(File.dirname(__FILE__), '..')

require 'charts'