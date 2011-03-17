module Snapshooter
  class KgbDeals < Base
    def initialize
      @base_url = 'http://www.kgbdeals.com'
      super
    end

    # cities
    def divisions
      # cache divisions
      return @divisions unless @divisions.empty?
      # fetch the sitemap
      get("/sitemap")
      # parse the results
      xpath("div[@class='city'] a").map{ |link| @divisions << {:href => link["href"], :text => link.text } }.flatten
      @divisions
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      get(deal.permalink, :full_path => true)
      xpath("h4").first.text.gsub(/[^0-9\.]/,'').to_i
    end

    # deals
    def crawl_new_deals!
      puts "#{self.class.to_s} is crawling"
      divisions.each do |division_hash|
        
        # Get the deals for this division
        get(division_hash[:href])
        
        # Find the site
        site     = Site.find_by_source_name("kgb_deals")
        
        # Find the division
        division = site.divisions.find_or_initialize_by_name(division_hash[:text])
        division.url = (base_url + division_hash[:href])
        division.save
        
        # Find all deal links for that division
        xpath("div[@id=sitemap_body] a").map{|link| 
          
          # Follow the links
          get(link["href"], :full_path => true)
          
          # Capture the price
          sale_price = xpath("div[@class='buy_link'] a").first.text.gsub(/[^0-9\.]/,'').to_f
          
          # Capture Actual Price
          actual_price = xpath("div[@id='deal_basic_left'] dl dd").first.text.gsub(/[^0-9\.]/,'').to_f
          
          # Capture the merchant name
          merchant_name = (xpath("li[@class='merchant_name']").first.text || "unknown").dasherize
          
          ex_time = @doc.search("dl[@class='expires'] dd").first.attributes
          
          expires_at = Time.parse("#{ex_time['ey'].value}/#{ex_time['em'].value}/#{ex_time['ed'].value} #{ex_time['eh'].value}:#{ex_time['ei'].value}:#{ex_time['es'].value}")
          
          raw_address = @doc.search("a[@id='deal_see_more_back']").first.attributes["deal_map_location"].value
          
          # Build attributes hash
          attributes = {
            :division => division,
            :name => link.text,
            :sale_price => sale_price,
            :actual_price => actual_price,
            :permalink => link["href"],
            :deal_id => merchant_name,
            :site_id => site.id,
            :expires_at => expires_at,
            :raw_address => raw_address
          }
          
          # Ensure we dont duplicate deals use unique deal identifier
          if deal = division.deals.active.find_or_create_by_deal_id(attributes)
            puts "#{self.class.to_s} Added #{deal.name}"
          end
          
          # Other usefull stuff.
          # hash[:discount] = xpath("dl[@class='discount'] dd").first.text.gsub(/[^0-9\.]/,'').to_f
          # hash[:actual_price] = xpath("div[@id='deal_basic_left'] dl dd").first.text.gsub(/[^0-9\.]/,'').to_f
          # hash[:purchase_count] = xpath("h4").first.text.gsub(/[^0-9\.]/,'').to_i
        }
      end
    end

  end
end