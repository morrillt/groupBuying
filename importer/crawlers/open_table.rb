class OpenTableCrawler < AutoIdCrawler
  def self.potential_deal_ids(&block)
    divisions_for_import.each do |division|
      autoincrement_filter(division, division.url_part, &block)
      
      division.update_attribute(:last_checked_at, Time.now)
    end
  end
end