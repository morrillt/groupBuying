require 'resque/job_with_status'
class BaseJob < Resque::JobWithStatus
  SPLIT_CRAWL_FOR     = ['living_social']
  SPLIT_SNAPSHOTS_FOR = ['groupon', 'living_social']#['travel_zoo']

  def enqueue_by_site(options={})                 
    total = Site.active.count
    num = 0
    Site.active.each {|site|
      report_status(num, total)
      self.class.create({:site_id => site.id}.merge(options))
      num += 1
    }
  end
  
  def execute_or_enqueue(site)    
    division_range = options['division_range']
    deals_range    = options['deals_range']
    
    if self.class == CrawlerJob && SPLIT_CRAWL_FOR.include?(site.source_name)
      if division_range
        yield division_range, self
      else
        enqueue_by_divisions(site, :count => site.divisions.count)
      end           
      return 
    end
                                                                                
    if self.class == SnapshotJob && SPLIT_SNAPSHOTS_FOR.include?(site.source_name)
      if deals_range
        yield deals_range, self
      else
        if site.source_name == 'groupon'
          enqueue_by_deals(site, :limit => site.snapshooter_class::DIVISION_LIMIT, :count => site.divisions.count) # Actually enqueue by divisions
          return
        end
        enqueue_by_deals(site, :count => site.deals.active.count)
      end 
      return 
    end
    
    if self.class == UpdateDealsJob && site.deals.count > site.snapshooter_class::DEAL_LIMIT
      if deals_range
        yield deals_range, self
      else
        enqueue_by_deals(site, :count => site.deals.count)
      end
      return
    end
    
    yield nil, self
  end
  
  def enqueue_by_divisions(site, options = {})
    count = options.delete(:count)
    limit = site.snapshooter_class::DIVISION_LIMIT  
    
    if limit == 0
      enqueue_self(:site_id => site.id, :division_range => [0, site.divisions.count])
      return
    end     

    groups = count / limit
    if groups == 0
      enqueue_self(:site_id => site.id, :division_range => [0, count]) 
      return 
    end
       
    groups.times{ |i|
      from = i*limit
      to = (i == groups-1 ? count : (i+1)*limit)
      enqueue_self(:site_id => site.id, :division_range => [from, to])
    }
  end  

  def enqueue_by_deals(site, options = {})
    count = options.delete(:count)
    limit = options.delete(:limit) || site.snapshooter_class::DEAL_LIMIT
    
    if limit == 0                             
      enqueue_self(:site_id => site.id, :deals_range => [0, site.deals.count])
      return
    end                                                 
    
    groups = count / limit
    
    enqueue_self(:site_id => site.id, :deals_range => [0, count]) and return if groups == 0
    
    groups.times{ |i|
      from = i*limit
      to = (i == groups-1 ? count : (i+1)*limit)
      enqueue_self(:site_id => site.id, :deals_range => [from, to])
    }
  end  
  
  # private 
    def enqueue_self(options={})
      self.class.create(options)
    end
  
    def report_status(num, total)
      at(num, total, "At #{num} of #{total}")
    end
  
end