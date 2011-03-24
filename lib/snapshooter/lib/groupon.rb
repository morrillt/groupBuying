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
      Groupon.deals(:deal_id => deal.deal_id).last.quantity_sold
    end
    
    def crawl_new_deals!
      super      
      
      divisions.map do |division|
        
        log "Processing Division: #{division.name}"
        
        # important!
        @division = division
        
        new_deal_attributes = {}

        Groupon.deals(:division => division.site_division_id).each do |groupon_deal|
          
          if division.url == "http://www.groupon.com/appleton"
            puts groupon_deal.options.inspect
            return
          end
          
          # calculate full price
          normal_price = [:price, :discount_amount].map do |key|
            groupon_deal[key] = (groupon_deal[key].gsub(/[^0-9]/,'').to_f * 0.01)
          end.sum
          
          new_deal_attributes[:name]               = groupon_deal.title
          new_deal_attributes[:sale_price]         = groupon_deal.price
          new_deal_attributes[:actual_price]       = normal_price
          new_deal_attributes[:lat]                = groupon_deal.division_lat
          new_deal_attributes[:lng]                = groupon_deal.division_lng
          new_deal_attributes[:expires_at]         = groupon_deal.end_date
          new_deal_attributes[:permalink]          = groupon_deal.deal_url
          new_deal_attributes[:deal_id]            = groupon_deal.id
          new_deal_attributes[:site_id]            = @site.id
          new_deal_attributes[:division]           = division

          save_deal!(new_deal_attributes)
        end
      end
    end
  end
end