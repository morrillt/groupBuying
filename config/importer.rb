# importer stuff
#require 'mechanize'
#require 'nokogiri'
require 'net/http'
require 'open-uri'
require 'json'

require 'groupon'
Groupon.api_key = '607cf68804bdf0459d117b6c79d2ff4526950550'

core = %w( url_tools cookie_tools base_importer base_crawler base_snapshooter html_selector html_snapshooter auto_id_crawler scraping_crawler)
core.each{ |file| require "#{Rails.root}/importer/core/#{file}.rb" }

Dir["#{Rails.root}/importer/{crawlers,models,snapshooters}/*.rb"].each { |filename| require filename }