require 'groupon'
require 'thread'

Groupon.api_key = '607cf68804bdf0459d117b6c79d2ff4526950550'

require File.dirname(__FILE__) + '/lib/base'
require File.dirname(__FILE__) + '/lib/crawler'
require File.dirname(__FILE__) + '/lib/outsider'
require File.dirname(__FILE__) + '/lib/deals/base_deal'

Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each       { |f| require f }
Dir["#{File.dirname(__FILE__)}/lib/deals/*.rb"].each { |f| require f }