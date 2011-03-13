require 'rubygems'
require 'daemons'

name      = 'importer'
root      = File.dirname(__FILE__) #File.join(File.dirname(__FILE__), '..')
pid_root  = root + '/../log'
pid_file  = "#{pid_root}/#{name}.pid"

if File.exist?(pid_file) and pid = File.read(pid_file).strip and system("kill -0 #{pid} &> /dev/null")
  puts "Already running = #{pid}"
  exit
else
  # clear out the file or the daemons gem will complain
  File.delete(pid_file) if File.exists?(pid_file)
end

Daemons.run(root + '/run_import.rb',
            {:mode => :exec,
             :dir => pid_root,
             :dir_mode => :normal,
             :log_output => true,
             :app_name => name})
