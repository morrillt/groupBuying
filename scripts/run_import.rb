#!/usr/bin/env ruby
Thread.abort_on_exception = false

require File.expand_path(File.join(*%w[ .. config environment ]), File.dirname(__FILE__))

# Site.active.each do |site|
#   site.deals.active.each(&:check_live_status)
#   
#   #site.importer.import_new_deals
# end

# nuke mongo stuff
# Mongoid.master.collections.reject { |c| c.name == 'system.indexes'}.each(&:drop)

log_path = File.join(File.expand_path(File.dirname(__FILE__)), 'log/import.log')
@threads = []
@restart_every        = 240.minutes
@check_threads_every  = 5.seconds
@chill                = 30.seconds

def watched_loop(&block)
  @threads << Thread.new do
    begin
      loop do
        puts "calling block"
        yield
        
        puts "sleeping"
        sleep @chill.to_i
      end
    rescue Exception => e
      puts e.inspect
      puts e.backtrace
      
      # File.open(log_path, 'a') do |f|
      #   f << "======================\n"
      #   f << "#{Time.now}\n"
      #   f << e.inspect + "\n"
      #   f << e.backtrace.join("\n") + "\n"
      #   raise e
      # end
    end
  end
end

[GrouponImporter, KgbDeals, LivingSocial, OpenTable, TravelZoo, TravelZooUk, HomeRun].each do |importer|
  watched_loop do
    importer.import_deals
  end
end

watched_loop do
  Snapshot.generate_diffs
end

watched_loop do
  Deal.active.needs_update.each do |deal|
    deal.import
  end
end

(@restart_every/@check_threads_every).times do
  # restart the main loop if any threads have died
  if @threads.any?{ |thread| not thread.alive? }
    puts "exiting - #{@threads.inspect}"
    exit
  end
  
  sleep @check_threads_every.to_i
end
