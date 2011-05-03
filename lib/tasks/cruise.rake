require 'rubygems'
require 'rake'
require 'fileutils'
require "bundler"
desc "Task for cruise Control"
task :cruise do
RAILS_ENV = ENV['RAILS_ENV'] = 'test'
sh "bundle install"
Bundler.setup(:default, :test)
