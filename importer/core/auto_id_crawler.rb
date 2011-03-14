class AutoIdCrawler < BaseCrawler
  # takes an AR relation and a block that yields new deal records when given an ID
  # stops looking for new records after 10 failures in a row
  class << self
    def start_id
      0
    end
    
    def max_failures
      30
    end
    
    # basically the number of pages we'll keep a db cache of not existing
    def max_skips
      100
    end
    
    # TODO: implement more logic around URLs & closed/failed deals, to eventually stop re-checking
    def autoincrement_filter(relation, prepend = nil, &block)
      # FIXME: deal_id is a string in the DB because some are strings, but that means INT sort doesn't work right
      last_existing_id = relation.deals.select('cast(deal_id as SIGNED) as deal_id').order('deal_id desc').limit(1).first.try(:deal_id)
      
      # pick the highest between the start ID and last existing ID
      # TODO: this all needs to be DB-driven, not hard-coded
      auto_id = [last_existing_id, start_id].compact.map(&:to_i).sort.last
      failures, skips = 0, 0
      
      # TODO: need code to have a max_skips, so we only check say 50 more than the start id
      while failures < max_failures and skips < max_skips
        auto_id += 1
        result = yield(prepend.to_s + auto_id.to_s)
        
        failures = case result
          when :active        then  0
          when :cached        then (skips += 1); failures
          when :nonexistent   then failures + 1
          when :invalid       then failures + 1
          else          (puts "unknown #{result}"; failures)
        end
        
        puts "failures: #{failures} / skips: #{skips}"
      end
    end
    
    def potential_deal_ids(&block)
      autoincrement_filter(site, &block)
    end
  end
end