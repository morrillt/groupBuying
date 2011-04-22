module Snapshooter
  class GrouponApi < Crawler
    DIVISION_LIMIT = 40 # For the future
    DEAL_LIMIT = 200
    
    def initialize(source_name)
      super(source_name)
      @base_url = 'http://api.groupon.com/v2'
      @strategy = :api
    end
    
    def divisions
      @site.divisions
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)     
      return 0 unless deal.division # new deal?
      find_existing_by_options(deal.deal_id, :division => deal.division.site_division_id, 
        :lat => deal.lat, 
        :lng => deal.lng).try(:quantity_sold) || 0
    end    
             
    def update_snapshots!(range = nil, snapshot_job = nil)
      log "Update snapshots: [#{range.join(',')}]"
      divisions_to_process = divisions
      divisions_to_process = divisions_to_process[range[0]..range[1]] if range
      
      # timeouted_divisions = divisions_to_process.map{|div|
      total = divisions_to_process.count
      num = 0
      divisions_to_process.map{|div|
        update_snapshots_for_division(div)
        snapshot_job.report_status(num, total) if snapshot_job
        num += 1
      }

      # log "Timeouted divisions: #{timeouted_divisions.collect(&:name).join(',')} (#{timeouted_divisions.count})"
      # timeouted_divisions.map {|div|
      #   update_snapshots_for_division(div)
      # }
    end
    
    def update_snapshots_for_division(division)
      success = true
      division_deals = division.deals.active
      log "Division: #{division.site_division_id}"
      # log "Deals: #{deals.count}"
      begin
        Groupon.deals(:division => division.site_division_id).each {|groupon_deal|
          # log "Deal: #{groupon_deal.id}"
          deal = division_deals.detect{|dd| groupon_deal.id == dd.deal_id }
          # log "Found: #{deal.permalink}" if deal
          if deal
            deal.take_mongo_snapshot!(groupon_deal.try(:quantity_sold) || nil)
          end
        }
      rescue Timeout::Error => e
        HoptoadNotifier.notify(e)
        log "GrouponAPI Error: #{e.message}"
        success = false
      end
      success
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
                         
    # IMPORTANT: rewrote update_deal because deal deal can be retrieved from API or CRAWLER
    # Crawl and update deal attributes
    #   params:
    #     <tt>attributes</tt>: array or string of attributes
    def update_deal_info(deal, attributes = nil)
      attributes ||= '*'

      if attributes.is_a? String and attributes != '*'
        attributes = attributes.split(' ')
      end

      crawler_deal = Grouponanalytics::Deal.new(nil, deal.permalink, @site.id)
      new_attrs = crawler_deal.to_hash(deal.division.name, deal.permalink)
      
      update_attributes = {}
      if attributes.to_s == '*'
        update_attributes = new_attrs
      else                     
        attributes.map {|ab|                   
          field = ab.to_sym    
          if field == :categories
            deal.update_categories
            new_value = nil
          else
            new_value = new_attrs[field]
          end
          if new_value
            update_attributes[field] = new_value
          end
        }
      end
      deal.update_attributes(update_attributes)
      deal.save!
    end
    
  end
end