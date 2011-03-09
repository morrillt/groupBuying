require File.expand_path(File.join(*%w[ config environment ]), File.dirname(__FILE__))

Site.active.each do |site|
  site.deals.active.each(&:check_live_status)
  
  site.importer.import_new_deals
end