require 'open-uri'
module Snapshooter
  class Base    
    attr_reader :base_url, :doc

    TELEPHONE_REGEX = /[0-9]*[\-\(\)]+[0-9\-\(\)]+/
    UK_TELEPHONE_REGEX = /[0-9]{3,5}\s+[0-9]{3,5}\s+[0-9]{3,5}/
    PRICE_REGEX = /[^0-9\.]/
    
    def initialize(site_id = nil)
      # setup a mechanize agent for crawling
      # disabled for now
      # @agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
      @deals     = []
      @divisions = []
      @doc       = Nokogiri::HTML("")
    end
    
    def detect_absolute_path(url, options)
      options[:full_path] = (url =~ /^http(.+)/i) ? true : false
    end
    
    def log(msg)
      unless Rails.env.test?
        pp "#{self.class.to_s} [#{Time.now.to_s}] #{msg}"
      end
    end
    
    def get(resource, options = {})
      url = options[:full_path] ? resource : (base_url + resource)
      begin
        @doc = Nokogiri::HTML(open(url))
      rescue OpenURI::HTTPError => e
        log e.message
      end
    end
           
    def xpath(path)
      (doc/path) || []
    end
    
    def crawl_new_deals!
      puts "#{self.class.to_s} is crawling"
    end
    
    def save_deal!(attributes)
      log attributes[:permalink]
      begin
        # Ensure we dont duplicate deals use unique deal identifier
        if old_deal = @division.deals.find_by_permalink(attributes[:permalink])
          if old_deal.expired? && old_deal.max_sold_count != attributes[:max_sold_count]
            old_deal.update_attribute(:max_sold_count, attributes[:max_sold_count])
            log "max_sold_count have been updated for expired_deal #{old_deal.name}"
          end
          log "Skipped #{old_deal.name}"
        else
          deal = @division.deals.active.create!(attributes)
          deal.take_first_mongo_snapshot!
          log "Added #{deal.name}"
        end
      rescue => e     
        log "Error: #{e.message}"
      end    
      deal  # Return deal only when create new entity
    end
    
    def split_address_telephone(address, country = :usa)
      telephone_regex = unless country == :usa || country.empty?
          self.class.const_get("#{country}_telephone_regex".upcase)
        else
          TELEPHONE_REGEX
        end
        
      match_data = address.match(telephone_regex)
      if match_data
        [address.gsub(telephone_regex, ''), match_data.to_s]
      else
        [address, nil]
      end
    end  
    
    def time_counter_to_expires_at(counter)
      expires = Time.now
      counter.map{|v,k|
        v = v.to_i
        case k 
          when 'd'
            expires += v.days
          when 'h'
            expires += v.hours
          when 'm'
            expires += v.minutes
          when 's'
            expires += v.seconds
        end  
      }
      expires
    end
    
  end
end