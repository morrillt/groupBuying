require 'bundler/capistrano'
require 'rvm/capistrano'


set :rvm_type, :user
set :rvm_ruby_string, 'ree@charts'

set :domain, 'group-buying.pogodan.com'
set :application, domain

default_run_options[:pty] = true
set :repository,  "git@github.com:morrillt/groupBuying.git"
set :scm, "git"
set :scm_username, "git"
set :deploy_via, "remote_cache"
set :git_enable_submodules, 1

set :use_sudo, false

ssh_options[:username] = 'root'

task :staging do
  server "50.56.83.165", :app, :web, :db, :primary => true
  set :bundle, "bundle"
  set :deploy_to, "/srv/gbd"
  ssh_options[:username] = 'gbd'
end

after "deploy:update_code" do
  # trust rvmrc
  run "rvm rvmrc trust #{release_path}"

  # link the default database.yml
  run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  
  # stop the importer
  run "rvm ruby #{release_path}/scripts/importer.rb stop"
  
  # remove stale importer pid if it exists
  run "[ -f #{release_path}/log/importer.pid ] && rm -f #{release_path}/log/importer.pid"
  
  # start the importer
  run "rvm ruby #{release_path}/scripts/importer.rb start"
end

namespace :deploy do
  task :start do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :restart do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end
