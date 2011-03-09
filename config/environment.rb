require "rubygems"
require "bundler"
Bundler.setup

require 'active_support/all'
require 'active_record'
require 'logger'
require 'meta_where'
require 'geocoder'

require 'sinatra'
require 'sinatra/logger'

require 'haml'

require File.join(File.expand_path(File.dirname(__FILE__)), 'importer')

############
environment = Sinatra::Application.environment.to_s || "test"
dbconfig = YAML.load(File.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection dbconfig[environment]

Dir['{lib,models}/*.rb'].each { |filename| require filename }
#enable  :logging
set     :root, File.join(File.dirname(__FILE__), '..')

require 'charts'