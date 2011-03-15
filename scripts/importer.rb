require 'rubygems'
require 'daemons'

root = File.dirname(__FILE__)

options = {
  :app_name => 'deal-importer',
  :ARGV => ARGV,
  :dir_mode => :normal,
  :dir => File.join(root, "..", "log"),
  :log_output => true,
  :multiple => false,
  :backtrace => true,
  :monitor => false
}

Daemons.run(root + "/run_import.rb RAILS_ENV=#{RAILS_ENV}", options)