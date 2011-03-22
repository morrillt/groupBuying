class DealCloserJob
  @queue = :deals

  def self.perform()
    puts "DealCloser Run"    
    
    Deal.active.each do |deal|
      if deal.expires_at.nil? || deal.expires_at <= Time.now
        # close the deal it has expired
        begin
          deal.close!
        rescue => e
          puts "Error:"
          puts "-"*90
          puts e.message
        end
      end
    end
  end

end
