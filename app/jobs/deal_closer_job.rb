class DealCloserJob
  @queue = :deals

  def self.perform()
    puts "Start DealCloser[#{Time.now}]"
    Deal.expired.active.each do |deal|
      begin
        deal.close!
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
      end
    end
    puts "DealCloser Finish"
  end

end
