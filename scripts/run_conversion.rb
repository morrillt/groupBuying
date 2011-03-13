require File.expand_path(File.join(*%w[ config environment ]), File.dirname(__FILE__))

[TravelZooUk, TravelZoo, OpenTable, Groupon].each do |site|
  puts "converting #{site.needs_conversion.count} records from #{site.model_name}"
  site.convert
end

puts "updating cached stats for #{Deal.never_cached.count + Deal.needs_update.count} deals"
Deal.update_cached_stats
