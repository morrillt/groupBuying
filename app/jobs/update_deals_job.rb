class UpdateDealsJob
   @queue = :deals
                                 
  # Crawl deals and update given attributes. Get divided by range
  #   prarms:
  #     <tt>site_id</tt>: Site ID
  #     <tt>options</tt>: :attributes - update given attributes
  #                       :range - update given range of deals
                
  def self.perform(site_id = nil, options = {})
    unless site_id
      puts "Start UpdateDealsJob[#{Time.now}]"
      Site.active.each do |site|
        Resque.enqueue(UpdateDealsJob, site.id)
      end      
      puts "UpdateDealsJob Finish"            
    else
      puts "UpdateDealsJob Start for #{site_id}"
      begin      
        site = Site.find(site_id)         
        site.crawl_and_update_deals_info(options)
      rescue => e
        puts "Error:"
        puts "-"*90    
        puts e.message
        puts e.backtrace.join("\n")
      end
      puts "UpdateDealsJob for #{site_id} - Finish"
    end
  end
  
end