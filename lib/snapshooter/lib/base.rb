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
      @doc       = Nokogiri::HTML("")
    end
    
    def log(msg)
      unless Rails.env.test?
        pp "#{self.class.to_s} [#{Time.now.to_s}] #{msg}"
      end
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
    
    def save_deal!(attributes)
      begin
        # Ensure we dont duplicate deals use unique deal identifier
        if deal = @division.deals.active.create!(attributes)
          log "Added #{deal.name}"
        else
          log "Skipped #{deal.name}"
        end
      rescue => e
        log "Error: #{e.message}"
      end
    end
  end
end