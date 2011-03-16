require 'digest/md5'

module Snapshooter
  class Base    
    def initialize
      # setup a mechanize agent for crawling
      @agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
      @deals = []
      @divisions = []
    end
    
    def get(resource, options = {})
      url = options[:full_path] ? resource : (base_url + resource)
      @doc = Hpricot(@agent.get(url).parser.to_s)
    end
    
    def base_url
      @base_url
    end
    
    def xpath(path)
      (@doc/path) || []
    end
    
    def self.tokenize(deal)
      Digest::MD5.hexdigest(deal.name + deal.permalink + deal.price.to_s)
    end
  end
end