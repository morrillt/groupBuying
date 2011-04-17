class CrawlerJob < BaseJob
  @queue = :crawler

  def perform      
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
  
  def perform_for_site(site_id)
    division_range = options['division_range']
    site = Site.find(site_id)
    
    execute_or_enqueue(site) do |division_range, crawler_job|
      puts "Divisions: [#{division_range.join('-')}]"  
      site.crawl_new_deals!(division_range, crawler_job)
    end
    
  end
   
end