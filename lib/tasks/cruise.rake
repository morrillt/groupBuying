require 'rubygems'
require 'rake'
require 'fileutils'
require "bundler"

task :prepare do
  sh "bundle install"
  Bundler.setup(:default, :test)
end

task :test =>['db:migrate', :spec] do
end


desc "Task for cruise Control"
  task :cruise => [:environment, :prepare, :test] do
end
