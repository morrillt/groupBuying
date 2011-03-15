RAILS_ROOT = File.dirname(File.dirname(__FILE__))

God.watch do |w|
  script = "rvm ruby #{RAILS_ROOT}/scripts/importer.rb"
  w.name = "deal-importer"
  w.group = "importers"
  w.interval = 60.seconds
  w.start = "#{script} start"
  w.stop = "#{script} stop"
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds
  w.pid_file = "#{RAILS_ROOT}/log/deal-importer.pid"
  
  w.behavior(:clean_pid_file)
  
  w.start_if do |start|
    start.conditions(:process_running) do |c|
      c.running = false
    end
  end
  
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
  
  
end