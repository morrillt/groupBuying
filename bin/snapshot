#!/usr/bin/ruby
require File.dirname(__FILE__) + '/../config/environment'

# Called hourly to update the snapshots for a sites active deals

Site.active.each do |site|
  site.update_snapshots!
end