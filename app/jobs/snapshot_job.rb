class SnapshotJob < BaseJob
  @queue = :snapshot
  
  def perform
    site_id        = options['site_id']
    
    # Divide and conquer
    unless site_id
      puts "Start SnapshotJob[#{Time.now}]"
      enqueue_by_site
    else      
      puts "Snapshot Start for #{site_id}"
      perform_for_site(site_id)
    end
    puts "Snapshot Finish"
  end
  
  def perform_for_site(site_id)
    deals_range = options['deals_range']
    site = Site.find(site_id)

    execute_or_enqueue(site) do |range, snapshot_job|
      puts "Deals: [#{range.join('-')}]" if range
      site.update_snapshots!(range, snapshot_job)
    end
  end
    
end