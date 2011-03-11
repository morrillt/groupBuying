class ScrapingCrawler < BaseCrawler
  class << self
    def potential_deal_ids
      # FIXME: need to do pagination
      puts "[#{to_s}]: scraping from #{divisions_for_import.count} divisions"
      divisions_for_import.each do |division|
        deal_ids = new(division).deal_ids
        puts "found #{deal_ids.size} in #{division.name}"
        
        deal_ids.each do |deal_id|
          yield deal_id, :division_id => division.id
        end
      
        division.update_attribute(:last_checked_at, Time.now)
      end
    end
  end
  
  attr_reader :url, :division
  def initialize(division)
    @division = division
  end
  
  def base_url
    self.class.base_url
  end
  
  def url
    @url ||= base_url + "/#{division.url_part}/deals"
  end
  
  def doc
    @doc ||= parse_url
  end
  
  def possible_deal_links
    doc.search(:a)
  end
  
  def deal_ids
    self.class.extract_from_links(possible_deal_links, deal_link_regex)
  end
end