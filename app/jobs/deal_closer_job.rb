class DealCloserJob
  @queue = :deals

  def self.perform()
    puts "DealCloser Run"
    Deal.expired.active.each do |deal|
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
