require 'rvm/capistrano'
require 'bundler/capistrano'
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

  run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end
