module TravelZooCrawlerCommon
  extend ActiveSupport::Concern
  
  def possible_deal_links
    doc.search('a.seeDetailsBtn')
  end
  
  def deal_link_regex
    %r[/local-deals/deal/(\d+)]
  end
  
  module ClassMethods
    def division_list_url
      "#{base_url}/local-deals"
    end
    
    def division_link_regex
      %r[/local-deals/(.*)/deals]
    end
    
    def possible_division_links
      divisions_doc.search('li a')
    end
  end
end

class TravelZooCrawler < ScrapingCrawler
  include TravelZooCrawlerCommon
  
  def self.base_url
    "http://www.travelzoo.com/local-deals"
  end
end

class TravelZooUkCrawler < ScrapingCrawler
  include TravelZooCrawlerCommon
  
  def self.base_url
    "http://www.travelzoo.com/uk/local-deals"
  end
end