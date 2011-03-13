# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

GroupBuying::Application.load_tasks

desc "Report code statistics"
task :stats do
#  require './vendor/code_statistics'
  
  STATS_DIRECTORIES = [
    %w(Controllers        app/controllers),
    %w(Helpers            app/helpers),
    %w(Models             app/models),
    %w(Libraries          lib/),
    %w(Importer           importer/),
    %w(Scripts            scripts/),
  ].collect { |name, dir| [ name, "./#{dir}" ] }.select { |name, dir| File.directory?(dir) }

  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end