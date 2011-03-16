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
      xpath("div[@class='city'] a").map{ |link| @divisions << {:href => link["href"], :text => link.html } }.flatten
      @divisions
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      get(deal.permalink, :full_path => true)
      xpath("h4").first.html.gsub(/[^0-9\.]/,'').to_i
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
        division = Division.find_or_create_by_name(division_hash[:text])
        
        # Find all deal links for that division
        xpath("div[@id=sitemap_body] a").map{|link| 
          
          # Follow the links
          get(link["href"], :full_path => true)
          
          # Capture the price
          price = xpath("div[@class='buy_link'] a").first.html.gsub(/[^0-9\.]/,'').to_f
          
          # Build attributes hash
          attributes = {
            :division => division,
            :site => site,
            :name => link.html,
            :price => price,
            :permalink => link["href"]
          }
          
          # Generate a unique token
          attributes[:token] = Snapshooter::Base.tokenize(Deal.new(attributes))
          
          # Ensure we dont duplicate deals
          if deal = Deal.find_or_create_by_token(attributes)
            puts "Added #{deal.name}"
          end
          
          # Other usefull stuff.
          # hash[:discount] = xpath("dl[@class='discount'] dd").first.html.gsub(/[^0-9\.]/,'').to_f
          # hash[:actual_price] = xpath("div[@id='deal_basic_left'] dl dd").first.html.gsub(/[^0-9\.]/,'').to_f
          # hash[:purchase_count] = xpath("h4").first.html.gsub(/[^0-9\.]/,'').to_i
        }
      end
    end

  end
end