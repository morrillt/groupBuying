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
      @mecha = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
      @deals     = []
      @divisions = []
      @doc       = @mecha
    end
    
    def detect_absolute_path(url, options)
      options[:full_path] = (url =~ /^http(.+)/i) ? true : false
    end
    
    def find_or_create_division(name, url = nil)
      options = {}
      detect_absolute_path(url, options)
      # Find the division
      @division = site.divisions.find_or_initialize_by_name(name)
      @division.source = site.source_name
      if url
        @division.url = options[:full_path] ? url : (base_url + url)
      end
      @division.save
    end 
                 
    # Capture divisions
    def divisions
    end       
    
    # Capture deal links from current page
    def deal_links
    end    
    
    # Capture pages links
    def pages_links   
    end
    
    # Deal links from other pages
    def capture_paginated_deal_links
    end  
    
    # Captures deal links on current and paginated links  
    def full_deal_links
      deal_links.concat capture_paginated_deal_links    
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal, full_path = true)
      get(deal.permalink, :full_path => full_path)
      buyers_count
    end                             
    
    def buyers_count    
      # Capture buyers_count in child
    end
    
    def detect_deal_division
      # Detect deal division(used with bruteforce crawling)
    end
             
    def crawl_deal(url, options)
      puts "Ping: #{url}"
      detect_absolute_path(url, options)

      get(url, options) do  
        # debugger
        unless error_page? @doc.uri.to_s
          detect_deal_division if options[:old_deals]
          deal = self.class::Deal.new(@doc, url, @site_id, options)
          save_deal!(deal.to_hash)
        else
          puts "Failed to get #{url}. Error page"
        end
      end
    end
    
    def crawl_division(url)   
      options = {}
      detect_absolute_path(url, options)
      get(url, options)
                    
      # debugger            
      full_deal_links.map do |deal_link|  
        crawl_deal(deal_link, options)
      end
    end  
    
    def crawl_new_deals!   
      puts "#{self.class.to_s} is crawling"
      # Find the site
      puts "#{site.name} is crawling"
      division_links = divisions
      division_links.map do |dhash|
        puts "Division: #{dhash[:url]}"
        options = {}
        div_url, div_name = dhash[:url], dhash[:name]        
                                                     
        # debugger
        find_or_create_division(div_name, div_url)
        crawl_division(div_url)        
      end           
    end
    
    def crawl_old_deals_with_bruteforce
      deals = site.deals                
      options = {:old_deals => true}
      return unless deals.count > 0
      detect_absolute_path(deals.first.permalink, options)
    
      # debugger
      brute_deals_links(deals) do |deal_link|
        crawl_deal(deal_link, options)
      end                             
    end     
        
    def base_deals_link_from_permalink(permalink = '')
      permalink.gsub(/[0-9]+/, '')
    end
    
    def brute_deals_links(deals, &block)
      base_link = base_deals_link_from_permalink(deals.first.try(:permalink)) # PLACEHOLDER?
      max_deal_id = deals.collect{|d| d.permalink.scan(/[0-9]+/).first.to_i}.max
      brute_links = (1..max_deal_id).collect {|i| deal_link = base_link + i.to_s}
      brute_links = brute_links - deals.collect(&:permalink) 
      brute_links.map {|deal_link|
        yield deal_link
      }
    end
      
    # url matchers for 404
    def error_page?(url)
      url =~ /local-deals\/error/# || url =~ /deals\/$/
    end
    
    def log(msg)
      unless Rails.env.test?
        pp "#{self.class.to_s} [#{Time.now.to_s}] #{msg}"
      end
    end
    
    def get(resource, options = {})
      url = options[:full_path] ? resource : (base_url + resource)
      begin
        # @doc = Nokogiri::HTML(open(url))
        @doc = @mecha.get(url)
        yield if block_given?
      rescue OpenURI::HTTPError => e
        log e.message
      rescue Mechanize::ResponseCodeError => e
        log e.message
      end
    end
           
    def xpath(path)
      (doc/path) || []
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
      counter.map{|k,v|
        v = v.to_i
        case k 
          when 'd', 'days'
            expires += v.days
          when 'h', 'hours'
            expires += v.hours
          when 'm', 'minutes'
            expires += v.minutes
          when 's', 'seconds'
            expires += v.seconds
        end  
      }
      expires
    end 
    
    class Deal
      def initialize(doc, site_id, options = {})
        @doc = doc
        @site_id = site_id
        @options = options
      end
    
      def name
      end
      
      def sale_price
      end
      
      def actual_price
      end
      
      def raw_address
      end
      
      def site
      end      
      
      def expires_at
      end
      
      def telephone   
        @telephone = Snapshooter::Base.new.split_address_telephone(raw_address).try(:last)
      end
                  
      def buyers_count
      end
      
      def lat              
        @lat = @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1].to_f
      end
    
      def lng     
        @lng = @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[2].to_f
      end         
      
      def permalink
        @permalink = @options[:full_path] ? @deal_link : (base_url + @deal_link)
      end
      
      def site_id
        @site_id
      end   
      
      def site
        @site ||= Site.find(@site_id)
      end      
      
      def sold_out?
        @sold_out ||= false
      end    
        
    
      def to_hash
        # debugger
        {
          :name => name,
          :site_id => site_id,
          :sale_price => sale_price,
          :actual_price => actual_price,
          :raw_address => raw_address,
          :lat => lat,
          :lng => lng,
          :expires_at => expires_at,
          :permalink => permalink,
          :telephone => telephone,
          :max_sold_count => buyers_count
        }
      end
    end
    
  end
end