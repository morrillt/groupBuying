class SnapshotJob
  @queue = :snapshot
  
  def self.perform(site_id = nil)
    puts "Snapshot Start for #{site_id}"            
    # Divide and conquer
    unless site_id
      Site.active.each do |site|
        Resque.enqueue(SnapshotJob, site.id)
      end
    else      
      begin
        Site.find(site_id).update_snapshots!
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
      end
    end
    puts "Snapshot Finish"
  end
    
end