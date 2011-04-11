module Snapshooter
  class GrouponCrawler < Crawler
    DIVISION_LIMIT = 50 # For the future
    DEAL_LIMIT = 200           
    
    def doc
      @doc
    end
    
    def self.crawl_deal(permalink, site_id, division)
      groupon_crawler = self.new('groupon')
      groupon_crawler.get(permalink, {:full_path => true})
      Deal.new(groupon_crawler.doc, permalink, site_id, :full_path => true)
    end
  end
end