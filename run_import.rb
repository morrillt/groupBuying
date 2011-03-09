require File.expand_path(File.join(*%w[ config environment ]), File.dirname(__FILE__))

# Site.active.each do |site|
#   site.deals.active.each(&:check_live_status)
#   
#   #site.importer.import_new_deals
# end

threads = []
[GrouponImporter, KgbDeals, LivingSocial, OpenTable, TravelZoo].each do |importer|
  threads << Thread.new { importer.import_deals }
end
threads.each(&:join)