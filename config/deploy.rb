set :stages, %w(staging production)
require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :domain, 'group-buying.pogodan.com'
set :application, domain

default_run_options[:pty] = true
set :repository,  "git@github.com:morrillt/groupBuying.git"
set :branch, "schema_changes"
#ssh_options[:keys] = ["~/.ec2/asanz.pem"]
set :scm, "git"
set :scm_username, "git"
set :deploy_via, "remote_cache"
set :git_enable_submodules, 1

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/vhosts/#{domain}"
set :use_sudo, false

ssh_options[:username] = 'capistrano'
ssh_options[:forward_agent] = true

#############################################################
#	Passenger
#############################################################

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  desc "Restart the application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

#############################################################
#       rake
#############################################################  

namespace :rake do  
  # run like: cap staging rake:invoke task=a_certain_task
  desc "Run a task on a remote server."  
  task :invoke do  
    run("cd #{deploy_to}/current; /usr/bin/env rake #{ENV['task']} RAILS_ENV=production")  
  end  
end

#############################################################
#	Shared stuff
#############################################################
task :after_update_code do
  # trust rvmrc
  run "rvm rvmrc trust #{release_path}"
  # 
  # ['stylesheets/all.css', 'javascripts/all.js'].each do |cached_content|
  #   run "rm -f #{release_path}/public/#{cached_content}"
  # end
  # 
  # ['db/production.sqlite3'].each do |shared_file|
  #   run "ln -nfs #{shared_path}/#{shared_file} #{release_path}/#{shared_file}"
  # end
end
