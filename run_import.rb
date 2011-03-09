require File.expand_path(File.join(*%w[ config environment ]), File.dirname(__FILE__))

# Site.active.each do |site|
#   site.deals.active.each(&:check_live_status)
#   
#   #site.importer.import_new_deals
# end

# nuke mongo stuff
# Mongoid.master.collections.reject { |c| c.name == 'system.indexes'}.each(&:drop)

threads = []
[GrouponImporter, KgbDeals, LivingSocial, OpenTable, TravelZoo].each do |importer|
  threads << Thread.new { importer.import_deals }
end

threads << Thread.new do
  loop do
    Snapshot.generate_diffs
    
    sleep 15
  end
end

@restart_every       = 240.minutes
@check_threads_every = 5.seconds

(@restart_every/@check_threads_every).times do
  # restart the main loop if any threads have died
  if threads.any?{ |thread| not thread.alive? }
    puts "exiting - #{threads.inspect}"
    exit
  end
  
  sleep @check_threads_every.to_i
end
