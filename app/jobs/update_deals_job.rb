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
      enqueue_by_site(options)
    else
      puts "UpdateDealsJob Start for #{site_id}"
      perform_for_site(site_id)
    end
    puts "UpdateDealsJob Finish"            
  end
  
  def perform_for_site(site_id)
    site = Site.find(site_id)         
    execute_or_enqueue(site) do |range, update_deals_job|
      puts "Update Deals: [#{range.join('-')}]" if range
      begin
        site.crawl_and_update_deals_info(options, update_deals_job)
      rescue => e
        puts e.message
        puts e.backtrace.join("\n")
        raise e
      end
    end                                             
  end
  
end