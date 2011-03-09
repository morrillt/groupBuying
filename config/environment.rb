require "rubygems"
require "bundler/setup"

require 'active_support/all'
require 'active_record'
require 'logger'
require 'meta_where'
require 'geocoder'

require 'sinatra'
require 'sinatra/logger'

require 'haml'

# reset root
root_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
Dir.chdir      root_path
set     :root, root_path

require File.join(File.expand_path(File.dirname(__FILE__)), 'importer')

############
environment = Sinatra::Application.environment.to_s || "test"
dbconfig = YAML.load(File.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection dbconfig[environment]

Dir['{lib,models}/*.rb'].each { |filename| require filename }
#enable  :logging

require 'charts'