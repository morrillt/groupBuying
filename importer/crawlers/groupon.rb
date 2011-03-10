class GrouponCrawler < BaseCrawler
  def self.potential_deal_ids
    divisions_for_import.each do |division|
      puts "checking #{division.name}"
      Groupon.deals(:division => division.division_id).each do |deal_hashie|
        
        yield deal_hashie.id
      end
      
      division.update_attribute(:last_checked_at, Time.now)
    end
  end
end