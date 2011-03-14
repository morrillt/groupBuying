class HomeRunCrawler < ScrapingCrawler
  class << self
    def base_url
      "http://www.homerun.com"
    end
    
    def division_list_url
      base_url
    end
    
    # TODO: paging needs extraction but only HomeRun is using it so far
    def pages
      %w(daily-steal city-sampler private-reserve hot-minute)
    end
    
    def division_link_regex
      /(\w+)/
    end
    
    def possible_division_links
      divisions_doc.search('.region-picker .vertical-list a')
    end
    
    def potential_deal_ids
      divisions_for_import.each do |division|
        pages.each do |page|
          new(division, page).deal_ids.each do |deal_id|
            yield deal_id, :division_id => division.id
          end
        end
      
        division.update_attribute(:last_checked_at, Time.now)
      end
    end
  end
  
  attr_reader :page
  def initialize(division, page = nil)
    @division, @page = division, page || self.class.pages.first
  end
  
  def possible_deal_links
    doc.search('.buy-buttons a')
  end
  
  def deal_link_regex
    %r[\/deal/([-\w]+)]
  end
  
  def url
    [base_url, division.url_part, page].join("/")
  end
end