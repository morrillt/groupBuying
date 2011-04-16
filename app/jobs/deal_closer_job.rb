class DealCloserJob
  @queue = :deals

  def self.perform(site_id = nil)
    # Divide and conquer
    unless site_id
      puts "Start DealCloserJob[#{Time.now}]"
      Site.active.each do |site|
        Resque.enqueue(DealCloserJob, site.id)
      end
    else
      site = Site.find(site_id)
      puts "Start DealCloserJob for [#{site.source_name}]"
      site.deals.expired.active.map do |deal|
        begin
          deal.close!
        rescue => e
          puts "Error:"
          puts "-"*90
          puts e.message
          puts e.backtrace.join("\n")
        end
      end
      puts "DealCloser Finish"
    end
  end

end
