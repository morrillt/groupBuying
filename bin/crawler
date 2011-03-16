#!/usr/bin/ruby
require File.dirname(__FILE__) + '/../config/environment'

# Called hourly to find new deals

Site.active.each do |site|
  site.snapshooter.crawl_new_deals!
end
