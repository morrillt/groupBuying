class CrawlerJob
   @queue = :crawler

  def self.perform(site_id = nil)   
    # Divide and conquer
    unless site_id
      puts "Start CrawlerJob[#{Time.now}]"
      Site.active.each do |site|
        Resque.enqueue(CrawlerJob, site.id)
      end
    else
      puts "CrawlerJob Start for #{site_id}"
      begin
        Site.find(site_id).snapshooter.crawl_new_deals!
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
      end
    end  
    puts "CrawlerJob Finish"
  end
   
end