$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'resque/tasks'
require 'resque_scheduler/tasks'
task "resque:setup" => :environment
