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
      Nokogiri::HTML(open(deal.permalink)).search("span[@class='number']").first.try(:text).to_i
    end
    
    def crawl_new_deals!
      super      
      
      divisions.map do |division|
        
        log "Processing Division: #{division.name}"
        
        # important!
        @division = division
        
        new_deal_attributes = {}
        
        Groupon.deals(:division => division.division_id).each do |deal_hash|
          
          # calculate full price
          normal_price = [:price, :discount_amount].map do |key|
            deal_hash[key] = (deal_hash[key].gsub(/[^0-9]/,'').to_f * 0.01)
          end.sum
          
          new_deal_attributes[:name]               = deal_hash[:title]
          new_deal_attributes[:sale_price]         = deal_hash[:price]
          new_deal_attributes[:actual_price]       = normal_price
          new_deal_attributes[:lat]                = deal_hash[:division_lat]
          new_deal_attributes[:lng]                = deal_hash[:division_lng]
          new_deal_attributes[:expires_at]         = deal_hash[:end_date]
          new_deal_attributes[:permalink]          = deal_hash[:deal_url]
          new_deal_attributes[:site_id]            = @site.id
          new_deal_attributes[:division]           = division

          save_deal!(new_deal_attributes)
        end
      end
    end
  end
end