class HomeRunCrawler < BaseCrawler
  def self.areas
    %w(daily-steal city-sampler private-reserve hot-minute)
  end
  
  def self.base_url
    "http://homerun.com/"
  end
  
  def self.potential_deal_ids
    divisions_for_import.each do |division|
      puts "scanning #{division.name}"
      areas.each do |area|
        url = base_url + "#{division.url_part}/#{area}"
        doc = Nokogiri::HTML(open(url))
        doc.search('.buy-buttons a').map{|a| a['href'].match(%r[\/deal/([-\w]+)]).try(:[], 1) }.compact.each do |deal_id|
          yield deal_id
        end
      end
      
      division.update_attribute(:last_checked_at, Time.now)
    end
  end
end