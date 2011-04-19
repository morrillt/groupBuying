# Require app/jobs              
Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
                  
# Redis config
config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
$redis = Redis.new(:host => config['host'], :port => config['port'], :thread_safe => true)
Resque.redis = $redis
              
# Scheduler tasks
require 'resque_scheduler'
Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")

# Resque Plugins                
require 'resque-meta'
require 'resque/status_server'
require 'resque/job_with_status'

# Resque status
Resque::Status.expire_in = (24 * 60 * 60) # 24hrs in seconds
     
     
# Hack for vegas
module Vegas
  class Runner         
    
    def port_open?(check_url = nil)
      begin
        check_url ||= url
        options[:no_proxy] ? open(check_url, :proxy => nil) : open(check_url)
        false
      rescue Errno::ECONNREFUSED => e
        true
      rescue Errno::EPERM => e
        # catches the "Operation not permitted" under Cygwin
        true
      rescue
        true
      end
    end
    
  end
end