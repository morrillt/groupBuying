#require 'bundler/capistrano'

set :domain, 'group-buying.pogodan.com'
set :application, domain

default_run_options[:pty] = true
set :repository,  "git@github.com:morrillt/groupBuying.git"
set :branch, "groupie"
set :scm, "git"
set :scm_username, "git"
set :deploy_via, "checkout"
#set :git_enable_submodules, 1

set :use_sudo, false

ssh_options[:username] = 'root'

task :staging do
  set :rails_env, "production" # for now
  server "50.56.83.165", :app, :web, :db, :primary => true
  #set :bundle, "bundle"
  set :deploy_to, "/srv/gbd"
  ssh_options[:username] = 'gbd'
end

task :dev do
  set :rails_env, "production"
  server "66.228.33.23", :app, :web, :db, :primary => true
  set :deploy_to, '/srv/gbd'
  ssh_options[:username] = 'gbd'
end


after "deploy:update_code" do
  run "rvm rvmrc trust #{release_path}"
  # link the default database.yml
  run "ln -s #{shared_path}/config/database_groupie.yml #{release_path}/config/database.yml"
end

namespace :deploy do
  task :start do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :restart do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
 
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{deploy_to}/current && /home/gbd/.rvm/gems/ree-1.8.7-2011.03@charts/bin/bundle install --quiet --without development test"
  end
end

namespace :compass do  
  desc 'Compile sass scripts'
  task :compile do
    system "rm -rf css/*"
    system "compass compile"
  end
end
 
after 'deploy:update_code', 'bundler:bundle_new_release'
after 'deploy:update_code', 'compass:compile'