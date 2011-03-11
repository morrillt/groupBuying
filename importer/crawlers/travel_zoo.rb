module TravelZooCrawlerCommon
  extend ActiveSupport::Concern
  
  module ClassMethods
    def division_list_url
      "#{base_url}/local-deals"
    end
    
    def deal_link_regex
      %r[#{base_url}/local-deals/deal/(\d+)]
    end
    
    def division_link_regex
      %r[#{base_url}/local-deals/(.*)/deals]
    end
    
    def possible_division_links
      cities_list = divisions_doc.search('#ctl00_Main_ctl00_LocationsRepeater_ctl00_CurrentLocationId').first.parent
      cities_list.children.search('li a')
    end
  end
end

class TravelZooCrawler < BaseCrawler
  include TravelZooCrawlerCommon
  
  def self.base_url
    "http://www.travelzoo.com"
  end
end

class TravelZooUkCrawler < BaseCrawler
  include TravelZooCrawlerCommon
  
  def self.base_url
    "http://www.travelzoo.com/uk"
  end
end