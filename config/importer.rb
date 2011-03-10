# importer stuff
require 'mechanize'
require 'nokogiri'
require 'net/http'
require 'open-uri'
require 'json'

require 'groupon'
Groupon.api_key = '607cf68804bdf0459d117b6c79d2ff4526950550'

%w(base url auto_id json rss).each{ |file| require "importer/importers/#{file}_importer.rb" }
Dir['importer/{sites,models}/*.rb'].each { |filename| require filename }