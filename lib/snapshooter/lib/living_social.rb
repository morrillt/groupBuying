module Snapshooter
  class LivingSocial < Base   
    def initialize
      site = Site.find_by_source_name('living_social')
      @base_url = site.base_url
      super
    end       
    
    
    def get(resource, options = {})
      url = options[:full_path] ? resource : (base_url + resource)
      begin                             
        @mecha ||= Mechanize.new
        get_resp = @mecha.get(url)        
        
        # Clicking through first box with city select
        if get_resp.links.first.href == '/?msc_id=1' 
          get_resp = get_resp.links.first.click
          get_resp = @mecha.get(url)
        end                                          
        
        # @doc = Nokogiri::HTML(open(url))
        @doc = get_resp
      rescue OpenURI::HTTPError => e
        log e.message
      end
    end
    
    
    def divisions
      return @divisions unless @divisions.empty?
      get("/cities")         
      @doc.links.map{|link|
        if link.href =~ %r[/cities/(.*)]
          @divisions << { :url => link.href, :name => link.text } 
        end
      }    
      @divisions
    end  
        
    def deal_links
      @doc.links.map{|link| 
        if link.href =~ %r[/deals/\d+(.*)]
          link.href.scan(%r[(/deals/\d+.*)/purchases/new]).first
          end
       }.flatten.compact
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      get(deal.permalink, :full_path => true)
      @doc.parser.search("div[@class='deal-price deal-price-lg']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
    end
    
    def crawl_new_deals!
      super 
      # Find the site
      site     = Site.find_by_source_name("living_social")
      
      divisions.map do |dhash|
        division_url = dhash[:url]        
        options = {}
        options[:full_path] = division_url =~ /^http(.+)/i
                
        # Find the division
        @division = site.divisions.find_or_initialize_by_name(dhash[:name])
        @division.source = site.source_name
        @division.url = options[:full_path] ? division_url : (base_url + division_url)
        @division.save
        
        get(division_url, options)
        
        deal_links.map do |deal_link|
          puts "Ping: #{deal_link}"
          options[:full_path] = (deal_link =~ /^http(.+)/i) ? true : false
          get(deal_link, options)
          
          living_social_deal = Snapshooter::LivingSocial::Deal.new(@doc, @base_url + deal_link, site.id, options)
          
          # Skip deal if no expiration time present
          if living_social_deal.sold_out?
            puts "Sold out"
            next
          end
                
          save_deal!(living_social_deal.to_hash)
          
        end
      end           
    end
  
    class Deal
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
        @sale_price ||= @doc.parser.search("div[@class='deal-price deal-price-lg']").try(:text).to_s.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end
    
      def actual_price
        savings = @doc.parser.css("ul.clearfix.deal-info li div.value").first.text.to_i
        if savings > 0 && sale_price > 0
          @actual_price ||= sale_price + sale_price * (savings * 0.01)
        end
        @actual_price.try(:round)
      end
    
      def raw_address
        @raw_address ||= @doc.parser.search("div.meta span.street_1").try(:text)
      end       
      
      def telephone   
        @telephone ||= @doc.parser.search("div.meta span.phone").try(:text)
      end
    
      def lat
        # @lat ||= @doc.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1]
      end
    
      def lng
        # @lng ||= @doc.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[2]
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
    
      def permalink
        @deal_link
      end
      
      def sold_out?
        @sold_out ||= false
      end    
      
      def site_id
        @site_id
      end
      
      def to_hash
        {
          :name => name,
          :site_id => site_id,
          :sale_price => sale_price,
          :actual_price => actual_price,
          :raw_address => raw_address,
          :telephone => telephone,
          :lat => lat,
          :lng => lng,
          :expires_at => expires_at,
          :permalink => permalink
        }
      end
    end     
  end
end