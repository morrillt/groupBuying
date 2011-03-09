class AutoIdImporter < UrlImporter
  # takes an AR relation and a block that yields new deal records when given an ID
  # stops looking for new records after 10 failures in a row
  class << self
    def start_id
      0
    end
    
    def max_failures
      10
    end
    
    # TODO: implement more logic around URLs & closed/failed deals, to eventually stop re-checking
    def autoincrement_filter(relation, prepend = nil, &block)
      auto_id = (relation.deals.order(:deal_id.desc).last.try(:deal_id) || start_id).to_i
      failures = 0
      
      while failures < max_failures
        auto_id += 1
        deal = new(prepend.to_s + auto_id.to_s)
        next if deal.cached? # skip this URL if we've already checked this hour
        
        puts "[#{failures} failures] auto-inc to #{auto_id}... exists?: #{deal.exists?.to_s}"
        failures = deal.exists? ? 0 : (failures + 1)
      
        yield deal
      end
    end
    
    def find_new_deals(&block)
      autoincrement_filter(site, &block)
    end
  end
end