class CrawlerJob
   @queue = :crawler

  def self.perform(site_id = nil)   
    puts "CrawlerJob Run"    
    
    # Divide and conquer
    unless site_id
      Site.active.each do |site|
        Resque.enqueue(CrawlerJob, site.id)
      end
    else
      begin
        Site.find(site_id).snapshooter.crawl_new_deals!
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
      end
    end  
  end
   
end