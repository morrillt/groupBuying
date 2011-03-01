require 'active_record'

class Environment
  def self.setup
    self.send(Sinatra::Application.settings.environment)
  end

  def self.test
    setup_active_record({ :user => "root",
                          :password => "root",
                          :database => "htmlParser_test" })
  end

  def self.development
    setup_active_record({ :user => "root",
                          :password => "root",
                          :database => "htmlParser" })
  end

  def self.setup_active_record(args)
    default = { :adapter => "mysql", :host => "localhost" }
    ActiveRecord::Base.establish_connection(default.merge(args))
  end
end

Environment.setup
