module Snapshooter
  class KgbDeals < Crawler

    def divisions
      # cache divisions
      return @divisions unless @divisions.empty?
      # fetch the sitemap
      get("/sitemap")
      # parse the results
      xpath("div[@class='city'] a").map{ |link| @divisions << {:url => link["href"], :name => link.text } }.flatten
      @divisions
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      get(deal.permalink, :full_path => true)
      buyers_count
    end   
    
    def buyers_count
      xpath("h4").first.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
    end   
    
    def deal_links
      xpath("div[@id=sitemap_body] a").collect{|t| t["href"]} - pages_links
    end                                                      
    
    # Captures pages links
    def pages_links   
      xpath("div[@id=paging_wrapper] a").collect{|t| t["href"]}
    end
    
    def capture_paginated_deal_links
      pages_links.collect{ |page|
        get(page, :full_path=>true)
        deal_links
      }.flatten
    end  

  end
end