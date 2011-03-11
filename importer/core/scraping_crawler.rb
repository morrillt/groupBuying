class ScrapingCrawler < BaseCrawler
  class << self
    def possible_links
      doc.search(:a)
    end
    
    def potential_deal_ids
    # FIXME: need to do pagination
    divisions_for_import.each do |division|
      url = base_url + "/#{division.url_part}/deals"
      puts "scanning #{division.name}: #{url}"
      
      doc = Nokogiri::HTML(open(url))
      extract_from_links(possible_links, deal_link_regex).each do |deal_id|
        yield deal_id, :division_id => division.id
      end
      
      division.update_attribute(:last_checked_at, Time.now)
    end
  end
end