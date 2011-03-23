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
        @division = site.divisions.find_or_initialize_by_name(division_url)
        @division.url = options[:full_path] ? division_url : (base_url + division_url)
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
          
          raw_address = @doc.search("div[@class='smallMap'] p").last.text
          raw_address, telephone = split_address_telephone(raw_address)
          
          attributes = {}
          
          attributes[:name]                 = @doc.search("h1").first.text
          #attributes[:buyers_count]         = @doc.search("span[@id='ctl00_Main_LabelBought']").text.to_i
          attributes[:sale_price]           = @doc.search("div[@class='detailsPageDealInfoPrice']").first.text.gsub(/[^0-9]/,'').to_f
          attributes[:actual_price]         = @doc.search("span[@class='origPriceValue']").first.text.gsub(/[^0-9]/,'').to_f
          attributes[:raw_address]          = raw_address
          attributes[:telephone]            = telephone
          #TODO!
          #attributes[:expires_at]           = time_left[0].days.from_now + time_left[1].hours +  time_left[2].minutes
          attributes[:permalink]            = options[:full_path] ? deal_link : (base_url + deal_link)
          attributes[:site_id]              = @site.id
          attributes[:division]             = @division
          
          save_deal!(attributes)
        end
      end
      
    end
    
  end
end