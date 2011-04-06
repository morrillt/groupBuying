module Snapshooter
  class OpenTable < Base
    def initialize
      @site     = Site.find_by_source_name('open_table')
      @site_id  = @site.id
      @base_url = site.base_url
      super
    end
    
    def divisions
      @site.divisions.collect{|d| {:url => d.url, :name => d.name}}
    end   
    
    def site
      @site ||= Site.find(@site_id)
    end
    
    def deal_links
      @doc.links.collect{|l|
        if l.href =~ /comment\/coupon\/\d+/
          l.href.gsub('comment/', '')
        elsif l.href =~ /coupon\/d+/
          l.href.to_s
        end
      }.compact.uniq   
    end              
    
    def pages_links   
      @doc.links.detect{|l| l.text == 'Recent Deals'}.href
    end
    
    def capture_paginated_deal_links
      get(pages_links)
      @doc.links.collect{|link| link.href if link.href =~ /^\/coupon\/\d+$/}.compact.uniq
    end         
    
    def error_page?(url)
      super || url =~ /.com\/$/
    end
        
    def buyers_count
      @doc.search("div[@id='dealTotalBought']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
    end                                                                                                   
    
    def detect_deal_division                                 
      link = @doc.search("a[@class='country_selected']").text.downcase
      find_or_create_division(link)
    end
    
    class Deal < Snapshooter::Base::Deal
      def initialize(doc, deal_link, site_id, options = {})
        @doc = doc                 
        @deal_link = deal_link                
        site = Site.find_by_source_name('open_table')
        @site_id = site.id
        @options = options
      end
    
      def name
        @doc.search("h1").first.try(:text).gsub("Today's Deal: ", '')
      end
    
      def sale_price
        @doc.search("div[@class='container-purchaseprice-buybtn']").first.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end
    
      def actual_price
        @doc.search("div[@class='deal-value']").first.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end             
      
      def buyers_count
        bc = @doc.search("div[@id='dealTotalBought']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
        bc = @doc.parser.to_s.scan(/totalSold\: (\d+)/).flatten.first.to_i if bc == 0
        bc
      end
    
      def raw_address    
        @raw_address ||= @doc.parser.to_s.scan(%r[\{ 'address': '(.*)'\}]).flatten.first
      end                      
          
      def lat              
        # @lat ||= @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1].to_f
      end
    
      def lng     
        # @lng ||= @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[2].to_f
      end   
      
      def base_url
        @base_url ||= Site.find(@site_id).base_url
      end
          
      def expires_at   
        stats_box = @doc.parser.css("div.container-countdown div div")
        if stats_box.size > 1
          expires_at = (stats_box[0].to_s + ' ' + stats_box[2].to_s).to_time
        elsif 
          timer = @doc.search('script').to_s.gsub(/\s+/, '').scan(/timer:[a-z0-9\,\:\{\}]*/).first.scan(/\{(.*)\}/).flatten.first
          time_counter = timer.split(',').map{|d| d.split(':')}
          expires_at = Snapshooter::Base.new.time_counter_to_expires_at(time_counter)
        end
        expires_at
      end
    end # OpenTable::Deal
    
  end # OpenTable
end # Snapshooter