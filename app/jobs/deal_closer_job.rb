class DealCloserJob < BaseJob
  @queue = :deals

  def perform
    site_id        = options['site_id']
    
    # Divide and conquer
    unless site_id
      puts "Start DealCloserJob[#{Time.now}]"
      enqueue_by_site
    else
      puts "DealCloserJob Start for [#{site.source_name}]"
      perform_for_site(site_id)
    end
    puts "DealCloser Finish"
  end       
  
  def perform_for_site(site_id)
    site = Site.find(site_id)
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
  end

end
