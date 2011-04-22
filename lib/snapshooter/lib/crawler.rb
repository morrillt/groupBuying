module Snapshooter     
  
  # Class handle basic crawling logic
  # Rewrite methods in subclasses if custom behavior needed
  class Crawler < Base
    DIVISION_LIMIT = 50
    DEAL_LIMIT = 500

    attr_reader :base_url, :doc
    attr_accessor :strategy, :crawler_job

    def initialize(source_name)
      @site     = Site.find_by_source_name(source_name)
      @site_id  = @site.id
      @base_url = @site.base_url
      @deals, @divisions = [], []
      @crawler_job = nil
      @strategy = :crawler # :api, #rss
      super
    end     
    
    def site
      @site ||= Site.find(@site_id)
    end                                                 
    
    def crawl_new_deals!(range = nil)
      @crawler_job = crawler_job
      puts "#{self.class.to_s} is crawling, source: #{@site.source_name}"
      division_links = divisions
      division_links.map do |dhash|
        puts "Division: #{dhash[:url]}"
        options = {}
        div_url, div_name = dhash[:url], dhash[:name]        
                                                     
        find_or_create_division(div_name, div_url)
        crawl_division(div_url)
      end           
    end              
    
    def crawl_division(url)   
      options = {}
      detect_absolute_path(url, options)
      get(url, options)
                    
      full_deal_links.map do |deal_link|  
        crawl_deal(deal_link, options)
      end
    end  
    
    def crawl_deal(url, options)
      puts "Ping: #{url}"
      detect_absolute_path(url, options)

      get(url, options) do
        unless error_page? @doc.uri.to_s
          detect_deal_division if options[:old_deals]
          deal = self.class::Deal.new(@doc, url, @site_id, options)
          save_deal!(deal.to_hash)
        else
          puts "Failed to get #{url}. Error page"
        end
      end
    end

    # Initialize Division
    # TODO: - @division as class variable is bad move
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
                 
    # Captures deal links on current and paginated links  
    def full_deal_links
      deal_links.concat(capture_paginated_deal_links).uniq
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal, full_path = true)
      get(deal.permalink, :full_path => full_path)
      buyers_count
    end                             
       
    # TODO:      
    def save_deal!(attributes, division = nil)
      division ||= @division
      log attributes[:permalink]
      begin
        # Ensure we dont duplicate deals use unique deal identifier
        if old_deal = division.deals.find_by_permalink(attributes[:permalink])
          if old_deal.expired? && old_deal.max_sold_count != attributes[:max_sold_count]
            old_deal.update_attribute(:max_sold_count, attributes[:max_sold_count])
            log "max_sold_count have been updated for expired_deal #{old_deal.name}"
          end
          log "Skipped #{old_deal.name}"
        else
          deal = division.deals.active.create!(attributes)
          deal.take_first_mongo_snapshot!
          log "Added #{deal.name}"
        end
      rescue => e     
        HoptoadNotifier.notify(e)
        log "Error: #{e.message}"
        # log "Error: " + e.backtrace.join("\n")
      end    
      deal  # Return deal only when create new entity
    end

    # Crawl and update deal attributes
    #   params:
    #     <tt>attributes</tt>: array or string of attributes
    def update_deal_info(deal, attributes = nil)
      attributes ||= '*'

      if attributes.is_a? String and attributes != '*'
        attributes = attributes.split(' ')
      end
      get(deal.permalink, :full_path => true)
      crawler_deal = self.class::Deal.new(@doc, deal.permalink, @site_id, :full_path => true)
      update_attributes = {}
      if attributes.to_s == '*'
        update_attributes = crawler_deal.to_hash
      else                     
        attributes.map {|ab|                   
          field = ab.to_sym    
          if field == :categories
            deal.update_categories
            new_value = nil
          else
            new_value = crawler_deal.send(field)
          end
          if new_value
            update_attributes[field] = new_value
          end
        }
      end
      deal.update_attributes(update_attributes)
      deal.save!
    end            

    
    # Methods for brute-scrapping old deals
    def crawl_old_deals_with_bruteforce
      deals = site.deals                
      options = {:old_deals => true}
      return unless deals.count > 0
      detect_absolute_path(deals.first.permalink, options)
    
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
      brute_links = (1..max_deal_id).collect {|i| base_link + i.to_s }
      brute_links = brute_links - deals.collect(&:permalink) 
      brute_links.map {|deal_link|
        yield deal_link
      }
    end
      
    # URL matchers for error page, like:
    #   url =~ /local-deals\/error/
    def error_page?(url)
    end    


    # Methods that needs to be implemented by subclasses
    # ==================================================
    # Capture divisions
    def divisions   
      raise 'Abstract method [divisions] doesnt implemented'
    end       
    
    # Capture deal links from current page
    def deal_links
      raise 'Abstract method [deal_links] doesnt implemented'
    end    
    
    # Capture pages links
    def pages_links   
      raise 'Abstract method [pages_links] doesnt implemented'
    end
    
    # Deal links from other pages
    def capture_paginated_deal_links
      raise 'Abstract method [capture_paginated_deal_links] doesnt implemented'
    end  
    
    def buyers_count    
      # Capture buyers_count in child
      raise 'Abstract method [buyers_count] doesnt implemented'
    end
    
    def detect_deal_division
      raise 'Abstract method [detect_deal_division] doesnt implemented'
      # Detect deal division(used with bruteforce crawling)
    end
    
  end
end
