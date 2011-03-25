$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'resque/tasks'
require 'resque_scheduler/tasks'
task "resque:setup" => :environment

namespace :resque do 
  desc 'start all background resque daemons' 
  task :start_daemons do
    mrake_start "resque_scheduler resque:scheduler" 
      workers_config.each do |worker, config|
      mrake_start "resque_#{worker} resque:work QUEUE=#{config['queues']} COUNT=#{config['count']}" 
    end
  end

  desc 'stop all background resque daemons' 
  task :stop_daemons do
    sh "./script/monit_rake stop resque_scheduler" 
    workers_config.each do |worker, config|
      sh "./script/monit_rake stop resque_#{worker} -s QUIT" 
    end
  end

  def self.workers_config
    YAML.load(File.open(ENV['WORKER_YML'] || 'config/resque_workers.yml')) 
  end                                                                    

  def self.mrake_start(task) 
    sh "nohup ./script/monit_rake start #{task} RAILS_ENV=production >> log/workers.log &"
  end 
end