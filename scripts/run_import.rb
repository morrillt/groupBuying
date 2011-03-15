#!/usr/bin/env ruby
#Thread.abort_on_exception = false

require File.expand_path(File.join('..', 'config', 'environment'), File.dirname(__FILE__))

log_path = File.join(File.expand_path(File.dirname(__FILE__)), 'log/import.log')
#@threads = []
#@restart_every        = 240.minutes
#@check_threads_every  = 5.seconds
@chill                = 30.seconds

def watched_loop(name, &block)
  #puts "adding thread #{name}, #{@threads.size}"
  
  #@threads << Thread.new do
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
  #end
end

Site.active.each do |site|
  # next if site.name == 'groupon'
  
  watched_loop("#{site.name} importer") do
    site.crawler.crawl_new_deals
  end
end

watched_loop "active deal checker" do
  Deal.active.needs_update.limit(100).each(&:import)
end

watched_loop "analyzer" do
  Analyzer.analyze_snapshots(100)
end

#(@restart_every/@check_threads_every).times do
#  puts "checking threads"
#  # restart the main loop if any threads have died
#  if @threads.any?{ |thread| not thread.alive? }
#    puts "exiting - #{@threads.inspect}"
#    exit
#  end
#  
#  sleep @check_threads_every.to_i
#end
