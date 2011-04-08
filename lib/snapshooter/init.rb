require 'groupon'
require 'thread'

Groupon.api_key = '607cf68804bdf0459d117b6c79d2ff4526950550'

# require File.dirname(__FILE__) + '/lib/base'
Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each       { |f| require f }
Dir["#{File.dirname(__FILE__)}/lib/deals/*.rb"].each { |f| require f }