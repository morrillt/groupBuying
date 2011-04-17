class CrawlerJob
  
  
  @queue = :crawler

  def perform(options={})
    site_id        = options['site_id']

    # Divide and conquer
    unless site_id
      puts "Start CrawlerJob[#{Time.now}]"
      enqueue_by_site
    else
      puts "CrawlerJob Start for #{site_id}"
      perform_for_site(site_id)
    end  
    puts "CrawlerJob Finish"
  end  
  
  def pefrorm_for_site(site_id, options={})
    division_range = options['division_range']
    site = Site.find(site_id)
    
    execute_or_enqueue do |division_range|
      site.crawl_new_deals!(division_range)
    end
    
    begin                                      
      
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
   
end