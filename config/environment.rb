require 'active_record'

dbconfig = YAML.load(File.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection dbconfig[Sinatra::Application.environment.to_s]
