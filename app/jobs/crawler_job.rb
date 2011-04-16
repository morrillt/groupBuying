class CrawlerJob
  SPLIT_CRAWL_FOR = ['living_social']
  
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
        if SPLIT_CRAWL_FOR.include? site.source_name
          if division_range
            site.crawl_new_deals!(division_range)
          else
            site.enqueue_by_divisions(CrawlerJob, :count => site.divisions.count)
          end
        else
          site.crawl_new_deals!
        end
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
        puts e.backtrace.join("\n")
      end
    end  
    puts "CrawlerJob Finish"
  end
   
end