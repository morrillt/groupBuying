#require 'bundler/capistrano'

set :domain, 'group-buying.pogodan.com'
set :application, domain
set :db_prefix, 'group_buying'

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
  set :deploy_to, '/home/deploy/groupie'
  ssh_options[:username] = 'deploy'
end


after "deploy:update_code" do
  run "/home/#{ssh_options[:username]}/.rvm/bin/rvm rvmrc trust #{release_path}"
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
    run "cd #{deploy_to}/current && /home/#{ssh_options[:username]}/.rvm/gems/ree-1.8.7-2011.03@charts/bin/bundle install --quiet --without development test"
  end
end

namespace :compass do  
  desc 'Compile sass scripts'
  task :compile do
    system "rm -rf css/*"
    system "compass compile"
  end
end    

namespace :resque do 
  desc "Stop the resque daemon" 
  task :stop, :roles => :resque do
    run "cd #{current_path} && RAILS_ENV=production WORKER_YML=#{resque_workers_yml} rake resque:stop_daemons; true"
  end

  desc "Start the resque daemon" 
  task :start, :roles => :resque do
    run "cd #{current_path} && RAILS_ENV=production WORKER_YML=#{resque_workers_yml} rake resque:start_daemons"
  end 
end
 
after 'deploy:update_code', 'bundler:bundle_new_release'
after 'deploy:update_code', 'compass:compile'
   
namespace :db do   
  desc "Creates the database.yml configuration file in shared path"
  task :setup, :except => { :no_release => true } do
    default_template = <<-EOF
    setup: &setup
      adapter: mysql2
      encoding: utf8
      host: localhost
      username: root
      password: 
    development:
      <<: *setup
      database: #{db_prefix}
    test:
      <<: *setup
      database: #{db_prefix}_test
    staging:
      <<: *setup
      database: #{db_prefix}_stage
    production:
      <<: *setup
      database: #{db_prefix}_live
    EOF
    config = ERB.new(default_template)

    run "mkdir -p #{shared_path}/config"
    put config.result(binding), "#{shared_path}/config/database_groupie.yml"
  end
end
after "deploy:setup",           "db:setup"   unless fetch(:skip_db_setup, false)


namespace :monit do
  desc "Generate monitrc file from template"
  task :setup do 
    monitrc = <<-EOF
    check process resque_scheduler 
      with pidfile #{current_path}/tmp/pids/resque_scheduler.pid 
      group resque 
      alert penkinv@gmail.com
      start program = "/bin/sh -c 'cd #{current_path}; RAILS_ENV=production ./script/monit_rake start resque_scheduler resque:scheduler'" 
      stop program = "/bin/sh -c 'cd #{current_path}; RAILS_ENV=production ./script/monit_rake stop resque_scheduler'"
    EOF
    YAML.load(File.open('config/resque_workers.yml')).each_pair do |worker, config|
      monitrc << <<-EOF
      check process resque_#{worker}
        with pidfile #{current_path}/tmp/pids/resque_#{worker}.pid 
        group resque 
        alert penkinv@gmail.com
        start program = "/bin/sh -c 'cd #{current_path}; RAILS_ENV=production ./script/monit_rake start resque_#{worker} resque:work QUEUE=#{config['queues']} COUNT=#{config['count']}'" 
        stop program = "/bin/sh -c 'cd #{current_path}; RAILS_ENV=production ./script/monit_rake  stop resque_#{worker}'" 
      EOF
    end
    
    config = ERB.new(monitrc)
    put config.result(binding), "#{current_path}/monitrc"
  end
  
  task :restart do 
    run "/etc/init.d/monit restart"
  end
  
end