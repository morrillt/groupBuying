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
      @doc.search("span[@class='peoplePurchasedValue']").text.to_i
    end
    
    def crawl_new_deals!
      super
      
      divisions.map(&:url).each do |division_url|
        options = {}
        
        
        site = Site.find_by_source_name('open_table')
        
        detect_absolute_path(division_url, options)
        
        # Find the division
        @division = site.divisions.find_or_initialize_by_url(division_url)
        @division.url = division_url
        @division.save
        
        get(division_url, options)
                
        deal_links.map do |deal_link|
          log "Ping: #{deal_link}"
          
          deal_url = 'http://spotlight.opentable.com' + deal_link
          
          get(deal_url, :full_path => true)
          
          # Parse time left
          time_left = @doc.search("span[@id='dealTimeLeftArea']").text.split(":").map!{ |t|
            t.gsub(/[^0-9]/,'').to_i
          }
          
          # Skip deal if no expiration time present
          if time_left.empty? || time_left.size < 3
            puts "Sold out"
            next
          end
          
          raw_address = @doc.search("span[@class='formattedAddress']").last.try(:text) || ''
          raw_address, telephone = split_address_telephone(raw_address)
          
          # need lat and lng, geocoding address for it          
          save_deal!({
            :name => @doc.search("h1").first.try(:text).gsub("Today's Deal: ", ''),
            :sale_price => @doc.search("div[@class='detailsPageDealInfoPrice']").first.text.gsub(/[^0-9]/,'').to_f,
            :actual_price => @doc.search("span[@class='origPriceValue']").first.text.gsub(/[^0-9]/,'').to_f,
            :raw_address => raw_address,
            :telephone => telephone,
            :expires_at => 1.week.from_now,
            :permalink => options[:full_path] ? deal_link : (base_url + deal_link),
            :site => @site,
            :division => @division
          })
        end
      end
      
    end
    
  end
end