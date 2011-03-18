require 'open-uri'
module Snapshooter
  class Base    
    attr_reader :base_url, :doc
    
    def initialize
      # setup a mechanize agent for crawling
      # disabled for now
      # @agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
      @deals     = []
      @divisions = []
      @doc       = ""
    end
    
    def get(resource, options = {})
      url = options[:full_path] ? resource : (base_url + resource)
      @doc = Nokogiri::HTML(open(url))
    end
           
    def xpath(path)
      (doc/path) || []
    end
    
    def crawl_new_deals!
      puts "#{self.class.to_s} is crawling"
    end
  end
end