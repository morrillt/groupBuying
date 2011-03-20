module Snapshooter
  class OpenTable < Base
    def initialize
      @base_url = 'http://spotlight.opentable.com/deal'
      @site     = Site.find_by_source_name('open_table')
      super
    end
    
    def divisions
      @site.divisions
    end
    
    def deal_links
      @doc.search("a[@class='link']").map{|link| link['href'] if link['href'] =~ %r[\/deal\/(.+)\/(\w+|\d+)]  }.compact
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      get(deal.permalink, :full_path => true)
      @doc.search("span[@id='ctl00_Main_LabelBought']").text.to_i
    end
    
    def crawl_new_deals!
      super      
      log "not crawling for right now"
      return true
      
      
      divisions.map(&:url).each do |division_url|
        options = {}
        
        detect_absolute_path(division_url, options)
                
        get(division_url, options)
                
        deal_links.map do |deal_link|
          log "Ping: #{deal_link}"
          
          deal_url = 'http://spotlight.opentable.com' + deal_link
          
          get(deal_url, :full_path => true)
          
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
          #attributes[:buyers_count]         = @doc.search("span[@id='ctl00_Main_LabelBought']").text.to_i
          attributes[:sale_price]           = @doc.search("span[@id='ctl00_Main_OurPrice']").text.gsub(/[^0-9]/,'').to_f
          attributes[:actual_price]         = @doc.search("span[@id='ctl00_Main_PriceValue']").text.gsub(/[^0-9]/,'').to_f
          attributes[:raw_address]          = @doc.search("div[@class='smallMap'] p").last.text
          attributes[:lat],attributes[:lng] = @doc.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1, 2]
          attributes[:expires_at]           = time_left[0].days.from_now + time_left[1].hours +  time_left[2].minutes
          attributes[:permalink]            = options[:full_path] ? deal_link : (base_url + deal_link)
          attributes[:site_id]              = @site.id
          attributes[:division]             = @division
          
          save_deal!(attributes)
          
        end
      end
      
    end
    
  end
end