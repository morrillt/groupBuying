module Snapshooter
  class LivingSocial < Base   
    def initialize
      @site     = Site.find_by_source_name('living_social')
      @site_id  = @site.id
      @base_url = site.base_url
      super
    end       
    

    def get(resource, options = {})
      url = options[:full_path] ? resource : (@base_url + resource)
      begin
        @doc = @mecha.get(url)
        
        # Clicking through first box with city select
        if @doc.links.first.text == "I'm already a subscriber, skip"
          @doc = @doc.links.first.click
          @doc = @mecha.get(url)
        end
        yield if block_given?
      rescue OpenURI::HTTPError => e
        log e.message
      rescue Mechanize::ResponseCodeError => e
        log e.message
      end
    end

    
    def divisions
      return @divisions unless @divisions.empty?
      get("/cities")         
      @doc.links.map{|link|
        if link.href =~ %r[/cities/\d+[a-z\-]*$] || link.href =~ %r[escapes.livingsocial.com]
          @divisions << { :url => link.href, :name => link.text } 
        end
      }         
      @divisions
    end  
        
    def deal_links
      @doc.links.collect{|link| 
        if link.href =~ %r[/deals/\d+(.*)]
          link.href.scan(%r[(.*/deals/\d+).*]).flatten.first 
        end
      }.flatten.compact.uniq
    end   
    
    def pages_links   
      @doc.links.collect{ |link| 
        if link.href =~ %r[/deals/past] || link.href =~ %r[/more_deals]
          link.href 
        end
      }.compact
    end
    
    def capture_paginated_deal_links      
      pages_links.collect{ |page|   
        get(page)
        deal_links
      }.flatten
    end
    
    # def error_page?(url)
    #   super || url =~ /deals\/$/
    # end
    
    def buyers_count    
      @doc.parser.search("li.purchased .value").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
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
    
    
    def detect_deal_division(old_deals = false)
      # Detect deal if escapes division
      if @doc.uri.to_s =~ /escapes\.livingsocial\.com/
        div = site.divisions.find_or_initialize_by_name("Escapes")
        if div.new_record?
          div.source = site.source_name
          div.url = 'http://escapes.livingsocial.com/deals'
          div.save
          return div
        else
          return div
        end
      elsif old_deals
        div_name = @doc.search("a[@class='market']").first.text
        find_or_create_division(div_name)
        @division
      end  
    end
             
    def crawl_deal(url, options)
      puts "Ping: #{url}"
      detect_absolute_path(url, options)
      get(url, options) do  
        unless error_page? @doc.uri.to_s
          deal = self.class::Deal.new(@doc, url, @site_id, options)
          save_deal!(deal.to_hash, detect_deal_division(options[:old_deals]) )
        else
          puts "Failed to get #{url}. Error page"
        end
      end
    end
    
    
    # def crawl_new_deals!
    #   # Find the site
    #   site     = Site.find_by_source_name("living_social")
    #   
    #   divisions.map do |dhash|
    #     options = {}
    #     div_url, div_name = dhash[:url], dhash[:name]        
    #     
    #     # Find the division
    #     find_or_create_division(div_name, div_url)
    #             
    #     get(division_url, options)
    #     
    #     deal_links.map do |deal_link|
    #       puts "Ping: #{deal_link}"
    #       options[:full_path] = (deal_link =~ /^http(.+)/i) ? true : false
    #       get(deal_link, options)
    #       
    #       living_social_deal = Snapshooter::LivingSocial::Deal.new(@doc, @base_url + deal_link, site.id, options)
    #       
    #       # Skip deal if no expiration time present
    #       if living_social_deal.sold_out?
    #         puts "Sold out"
    #         next
    #       end
    #             
    #       save_deal!(living_social_deal.to_hash)
    #       
    #     end
    #   end           
    # end  
  
    class Deal < Snapshooter::Base::Deal
      def initialize(doc, deal_link, site_id, options = {})
        @doc = doc
        @deal_link = deal_link                
        @site_id = site_id
        @options = options
      end
    
      def name
        @name ||= @doc.parser.search("div[@class='deal-title']").try(:text).gsub("\n", '').gsub(/\s+/, ' ')
      end
    
      def sale_price
        @sale_price = @doc.parser.search("div[@class='deal-price deal-price-lg']").try(:text).to_s.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
        if @sale_price == 0
          @sale_price = @doc.parser.search("div[@class='deal-price deal-price-sm']").try(:text).to_s.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f 
        end    
        @sale_price
      end
    
      def actual_price
        original_price = @doc.parser.css("p.original-price del").first
        if original_price
          @actual_price = original_price.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
        else
          savings = @doc.parser.css("ul.clearfix.deal-info li div.value").first.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
          if savings > 0 && sale_price > 0
            @actual_price = sale_price / (1 - (savings * 0.01))
          end
        end
        @actual_price.try(:round)
      end
    
      def raw_address
        @raw_address = @doc.parser.search("div.meta span.street_1").try(:text)
      end       
      
      def telephone   
        @telephone = @doc.parser.search("div.meta span.phone").try(:text)
      end
    
      def lat                                                           
        @lat = @doc.parser.to_s.match(%r["coordinate":\[([-\d\.]+),([-\d\.]+)\]])
        @lat[1].to_f if @lat
      end
    
      def lng
        @lng = @doc.parser.to_s.match(%r["coordinate":\[([-\d\.]+),([-\d\.]+)\]])
        @lat[2].to_f if @lng
      end         
      
      def buyers_count      
        @doc.parser.search("li.purchased .value").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
      end
          
      def expires_at
        return @time_left if @time_left
        # Parse javascript counter
        @time_left = Time.now
        JSON.parse(@doc.parser.text.scan(%r[counter\((.*)\)]).flatten.first).map{|v,k|
          v = v.to_i
          case k 
            when 'd'
              @time_left += v.days
            when 'h'
              @time_left += v.hours
            when 'm'
              @time_left += v.minutes
            when 's'
              @time_left += v.seconds
          end
        }
        @time_left
      end
      
    end     
  end
end