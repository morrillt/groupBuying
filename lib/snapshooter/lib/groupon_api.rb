module Snapshooter
  class GrouponApi < Crawler
    DIVISION_LIMIT = 50 # For the future
    DEAL_LIMIT = 200
    
    def initialize(source_name)
      super(source_name)
      @base_url = 'http://api.groupon.com/v2'
    end
    
    def divisions
      @site.divisions
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)     
      return 0 unless deal.division # new deal?
      find_existing_by_options(:division => deal.division.site_division_id, 
        :lat => deal.lat, 
        :lng => deal.lng).try(:quantity_sold) || 0
    end
    
    def crawl_new_deals!(range = nil) # FIXME: range is not implemented yet
      deals_permalinks = site.deals.active.collect(&:permalink)
      divisions.map do |division|
        log "Processing Division: #{division.name}"
        
        # important!
        @division = division
        
        Groupon.deals(:division => division.site_division_id).each do |groupon_deal|
          next if deals_permalinks.include? groupon_deal.deal_url
          
          save_deal!(Deal.new(groupon_deal).to_hash(@site_id, division))
        end
      end
    end
    
    def find_existing_by_lat_lng(deal_id, lat, lng)
      find_existing_by_options(deal_id, {:lat => lat, :lng => lng})
    end
  
    def find_existing_by_options(deal_id, options = {})
      Groupon.deals(options).detect{|d| d.id == deal_id }
    end

    def self.find_at_groupon_by_division_and_permalink(division, permalink)
      Groupon.deals(:division => division).detect{|d| d.deal_url == permalink }#.try(:first)
    end
    
  end
end