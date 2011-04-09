class CrawlerJob
  DIVISION_LIMIT = 10
  @queue = :crawler

  def self.perform(site_id = nil, division_range = nil)
    # Divide and conquer
    unless site_id
      puts "Start CrawlerJob[#{Time.now}]"
      Site.active.each do |site|
        Resque.enqueue(CrawlerJob, site.id)
      end
    else
      puts "CrawlerJob Start for #{site_id}"
      begin
        site = Site.find(site_id)
        if site.source_name == 'living_social'
          if division_range
            site.snapshooter.crawl_new_deals!(division_range)
          else
            site.snapshooter.enqueue_by_divisions
          end
        else
          Site.find(site_id).snapshooter.crawl_new_deals!
        end
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
      end
    end  
    puts "CrawlerJob Finish"
  end
   
end