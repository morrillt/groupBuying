require 'bundler/capistrano'
require 'rvm/capistrano'


set :rvm_type, :user
set :rvm_ruby_string, 'ree@charts'
set :shared_bundler_gems_path, "/srv/gbd/shared/bundle/ruby/1.8/gems"

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
  set :rails_env, "production" # for now
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
  
  # start the importer god monitor process
  run "#{shared_bundler_gems_path}/god-0.11.0/bin/god -c #{release_path}/config/importer.god"
end

namespace :deploy do
  task :start do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :restart do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end
