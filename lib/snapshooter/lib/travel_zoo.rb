module Snapshooter
  class TravelZoo < Base
    def initialize
      @base_url = 'http://www.travelzoo.com'
      super
    end
    
    def divisions
      return @divisions unless @divisions.empty?
      get("/local-deals")
      @doc.search("li a").map{|link|  
        if link['href'] =~ %r[/local-deals/(.*)/deals]
          @divisions << { :url => link["href"], :name => link.text } 
        end
      }
      @divisions
    end
    
    def deal_links
      @doc.search("a[@class='seeDetailsBtn']").map{|link| link['href'] if link['href'] =~ %r[/local-deals/deal/(\d+)]  }.compact
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      get(deal.permalink, :full_path => true)
      @doc.search("span[@id='ctl00_Main_LabelBought']").text.to_i
    end
    
    def crawl_new_deals!
      super
      
      # Find the site
      site     = Site.find_by_source_name("travel_zoo")
      
      divisions.map do |dhash|
        division_url = dhash[:url]        
        options = {}
        options[:full_path] = division_url =~ /^http(.+)/i
        
        
        # Find the division
        @division = site.divisions.find_or_initialize_by_name(dhash[:name])
        @division.source = "travel_zoo"
        @division.url = options[:full_path] ? division_url : (base_url + division_url)
        @division.save
        
        get(division_url, options)
        
        deal_links.map do |deal_link|
          puts "Ping: #{deal_link}"
          options[:full_path] = (deal_link =~ /^http(.+)/i) ? true : false
          get(deal_link, options)
          
          travel_zoo_deal = Snapshooter::TravelZoo::Deal.new(@doc, deal_link, site.id, options)
          
          # Skip deal if no expiration time present
          if travel_zoo_deal.sold_out?
            puts "Sold out"
            next
          end
                
          save_deal!(travel_zoo_deal.to_hash)
          
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
        @name ||= @doc.search("span[@id='ctl00_Main_LabelDealTitle']").try(:text)
      end
    
      def sale_price
        @sale_price ||= @doc.search("span[@id='ctl00_Main_OurPrice']").try(:text).to_s.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end
    
      def actual_price
        @actual_price ||= @doc.search("span[@id='ctl00_Main_PriceValue']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end
    
      def raw_address
        @raw_address ||= @doc.search("div[@class='smallMap'] p").children.map{|c| c.try(:text).to_s }.join(" ")
      end
    
      def lat
        @lat ||= @doc.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1]
      end
    
      def lng
        @lng ||= @doc.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[2]
      end
    
      def expires_at
        if @time_left
          return @time_left
        else
          # Parse time left
          @time_left = @doc.search("span[@id='ctl00_Main_TimeLeft']").text.split(",").map!{ |t|
            t.gsub(/[^0-9]/,'').to_i
          }
          if @time_left.empty? || @time_left.size < 3
            @sold_out = true
            return 1.minute.ago
          else
            return(@time_left[0].days.from_now + @time_left[1].hours +  @time_left[2].minutes)
          end
        end
      end
    
      def permalink
        @permalink ||= @options[:full_path] ? @deal_link : (base_url + @deal_link)
      end
    
      def telephone
        @telephone ||= Snapshooter::Base.new.split_address_telephone(raw_address).try(:last)
      end
      
      def sold_out?
        @sold_out ||= false
      end    
      
      def site_id
        @site_id || Site.find_by_source_name("travel_zoo").id
      end
      
      def to_hash
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
          :telephone => telephone
        }
      end
    end 
    
  end
end