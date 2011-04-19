class UpdateDealsJob < BaseJob
   @queue = :deals
                                 
  # Crawl deals and update given attributes. Get divided by range
  #   prarms:
  #     <tt>site_id</tt>: Site ID
  #     <tt>options</tt>: :attributes - update given attributes
  #                       :range - update given range of deals                
  def perform
    site_id        = options['site_id']
    
    unless site_id
      puts "Start UpdateDealsJob[#{Time.now}]"
      enqueue_by_site
    else
      puts "UpdateDealsJob Start for #{site_id}"
      perform_for_site(site_id)
    end
    puts "UpdateDealsJob Finish"            
  end
  
  def perform_for_site(site_id)
    begin      
      site = Site.find(site_id)         
      site.crawl_and_update_deals_info(options)
    rescue => e
      puts "Error:"
      puts "-"*90    
      puts e.message
      puts e.backtrace.join("\n")
    end
  end
  
end