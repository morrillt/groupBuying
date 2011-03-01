require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :host => "localhost",
  :user => "root",
  :password => "root",
  :database => "htmlParser"
)

class Groupon < ActiveRecord::Base
  set_table_name "groupon"
end

p Groupon.first
