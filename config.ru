$:.unshift File.dirname(__FILE__)
require 'charts'
require 'config/environment'


run Sinatra::Application

