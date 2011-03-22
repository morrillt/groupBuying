class SnapshotJob
  @queue = :snapshot
  
  def self.perform()
    puts "Snapshot Run"        
    Site.active.map do |site|
      begin
        site.update_snapshots!
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
      end
    end
  end
    
end