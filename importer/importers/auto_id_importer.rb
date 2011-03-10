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
      # FIXME: deal_id is a string in the DB because some are strings, but that means INT sort doesn't work right
      last_existing_id = relation.deals.select('cast(deal_id as SIGNED) as deal_id').order('deal_id desc').limit(1).first.try(:deal_id)
      
      auto_id = (last_existing_id || start_id).to_i
      failures = 0
      
      # TODO: need code to have a max_skips, so we only check say 50 more than the start id
      while failures < max_failures
        auto_id += 1
        deal = new(prepend.to_s + auto_id.to_s)
        next if deal.cached? # skip this URL if we've already checked this hour
        
        puts "[#{failures} failures] auto-inc to #{auto_id}... exists?: #{deal.deal_exists?.to_s}"
        failures = deal.deal_exists? ? 0 : (failures + 1)
        
        yield deal
      end
    end
    
    def find_new_deals(&block)
      autoincrement_filter(site, &block)
    end
  end
end