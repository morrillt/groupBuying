module Snapshooter
  class TravelZoo < Base
    def initialize
      @base_url = 'http://www.travelzoo.com'
      super
    end
    
    def divisions
      return @divisions unless @divisions.empty?
      get("/local-deals")
      @doc.search("li a").map{|link| link['href'] if link['href'] =~ %r[/local-deals/(.*)/deals]  }.compact
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
      
      divisions.map do |division_url|
        options = {}
        options[:full_path] = division_url =~ /^http(.+)/i
        
        
        # Find the division
        division = site.divisions.find_or_initialize_by_name(division_url)
        division.url = options[:full_path] ? division_url : (base_url + division_url)
        division.save
        
        get(division_url, options)
        
        deal_links.map do |deal_link|
          puts "Ping: #{deal_link}"
          options[:full_path] = (deal_link =~ /^http(.+)/i) ? true : false
          get(deal_link, options)
          
          # Parse time left
          time_left = @doc.search("span[@id='ctl00_Main_TimeLeft']").text.split(",").map!{ |t|
            t.gsub(/[^0-9]/,'').to_i
          }
          
          # Skip deal if no expiration time present
          if time_left.empty? || time_left.size < 3
            puts "Sold out"
            next
          end
          
          attributes = {}
          
          attributes[:name]                 = @doc.search("span[@id='ctl00_Main_LabelDealTitle']").text
          attributes[:deal_id]              = (@doc.search("span[@id='ctl00_Main_MerchantInMapBox']").text+attributes[:name])
          #attributes[:buyers_count]         = @doc.search("span[@id='ctl00_Main_LabelBought']").text.to_i
          attributes[:sale_price]           = @doc.search("span[@id='ctl00_Main_OurPrice']").text.gsub(/[^0-9]/,'').to_f
          attributes[:actual_price]         = @doc.search("span[@id='ctl00_Main_PriceValue']").text.gsub(/[^0-9]/,'').to_f
          attributes[:raw_address]          = @doc.search("div[@class='smallMap'] p").last.text
          attributes[:lat],attributes[:lng] = @doc.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1, 2]
          attributes[:expires_at] = time_left[0].days.from_now + time_left[1].hours +  time_left[2].minutes
          attributes[:permalink] = options[:full_path] ? deal_link : (base_url + deal_link)
          attributes[:site_id] = site.id
          
          # Ensure we dont duplicate deals use unique deal identifier
          if deal = division.deals.active.find_or_create_by_deal_id(attributes)
            puts "#{self.class.to_s} Added #{deal.name}"
          end
          
        end
      end
      
    end
    
  end
end