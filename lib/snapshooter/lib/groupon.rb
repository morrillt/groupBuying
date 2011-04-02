module Snapshooter
  # named GrouponClass to prevent conflicts with groupon gem
  class GrouponClass < Base
    def initialize
      @base_url = 'http://api.groupon.com/v2'
      @site     = Site.find_by_source_name('groupon')
      super
    end
    
    def divisions
      @site.divisions
    end
    
    def deal_links
      @doc.search("h2[@class='control_title'] a").map{|link| link['href']  }.compact
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      Groupon.deals(:division => deal.division.site_division_id, :lat => deal.lat, :lng => deal.lng).detect{|d| 
        d.id == deal.deal_id
      }.try(:quantity_sold)
    end
    
    def crawl_new_deals!
      super      
      
      divisions.map do |division|
        
        log "Processing Division: #{division.name}"
        
        # important!
        @division = division
        
        Groupon.deals(:division => division.site_division_id).each do |groupon_deal|
          
          # Build the full address
          full_address = ""
          if groupon_deal.redemptionLocations
            full_address << groupon_deal.redemptionLocations.first.try(:streetAddress1).to_s + "\n"
            full_address << groupon_deal.redemptionLocations.first.try(:streetAddress2).to_s + "\n"
            full_address << groupon_deal.redemptionLocations.first.try(:city).to_s + ", "
            full_address << groupon_deal.redemptionLocations.first.try(:state).to_s + "\n"
            full_address << groupon_deal.redemptionLocations.first.try(:postalCode).to_s
          end
          
          
          # calculate full price
          normal_price = [:price, :discount_amount].map do |key|
            groupon_deal[key] = (groupon_deal[key].gsub(Snapshooter::Base::PRICE_REGEX,'').to_f * 0.01)
          end.sum
          
          save_deal!({
            :name => groupon_deal.title,
            :sale_price => groupon_deal.price,
            :actual_price => normal_price,
            :lat => groupon_deal.division_lat,
            :lng => groupon_deal.division_lng,
            :expires_at => groupon_deal.end_date,
            :permalink => groupon_deal.deal_url,
            :deal_id => groupon_deal.id,
            :site => @site,
            :division => division,
            :raw_address => full_address,
            :telephone => "",
            :active => true,
            # :max_sold_count => capture_deal(groupon_deal)
          })
        end
      end
    end
  end
end