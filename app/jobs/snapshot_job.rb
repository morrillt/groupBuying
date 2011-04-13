class SnapshotJob
  SPLIT_SNAPSHOTS_FOR = ['groupon']   
  
  @queue = :snapshot
  
  def self.perform(site_id = nil, deal_range = nil)
    # Divide and conquer
    unless site_id
      puts "Start SnapshotJob[#{Time.now}]"
      Site.active.each do |site|
        Resque.enqueue(SnapshotJob, site.id)
      end
    else      
      puts "Snapshot Start for #{site_id}"
      begin       
        site = Site.find(site_id)
        if SPLIT_SNAPSHOTS_FOR.include? site.source_name
          if deal_range
            site.update_snapshots!(deal_range)
          else
            site.enqueue_by_deals(SnapshotJob, :count => site.deals.active.count)
          end
        else
          site.update_snapshots!
        end
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
      end
    end
    puts "Snapshot Finish"
  end
    
end