require 'bundler/capistrano'

set :domain, 'group-buying.pogodan.com'
set :application, domain

default_run_options[:pty] = true
set :repository,  "git@github.com:morrillt/groupBuying.git"
set :branch, "groupie"
set :scm, "git"
set :scm_username, "git"
set :deploy_via, "remote_cache"
set :git_enable_submodules, 1

set :use_sudo, false

ssh_options[:username] = 'root'

task :staging do
  set :rails_env, "production" # for now
  server "50.56.83.165", :app, :web, :db, :primary => true
  set :bundle, "bundle"
  set :deploy_to, "/srv/gbd"
  ssh_options[:username] = 'gbd'
end

after "deploy:setup", "deploy:god:restart"

after "deploy:update_code" do

  # link the default database.yml
  run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end

namespace :deploy do
  task :start do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :restart do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end