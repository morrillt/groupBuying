# importer stuff
require 'mechanize'
require 'nokogiri'
require 'net/http'
require 'open-uri'
require 'json'
require 'mongoid'

require 'groupon'
Groupon.api_key = '607cf68804bdf0459d117b6c79d2ff4526950550'

configure do
   Mongoid.configure do |config|
    name = "group_buying"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
    # config.slaves = [
    #   Mongo::Connection.new(host, 27017, :slave_ok => true).db(name)
    # ]
    #config.persist_in_safe_mode = false
  end
end

%w(base url auto_id json rss).each{ |file| require File.join(File.expand_path(File.dirname(__FILE__)), "/../importer/importers/#{file}_importer.rb") }
Dir['importer/{sites,models}/*.rb'].each { |filename| require filename }