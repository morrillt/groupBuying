module Snapshooter
  class OpenTable < Crawler
    def divisions
      @site.divisions.collect{|d| {:url => d.url, :name => d.name}}
    end   
    
    def site
      @site ||= Site.find(@site_id)
    end
    
    def deal_links
      @doc.links.collect{|l|
        if l.href =~ /comment\/coupon\/\d+/
          l.href.gsub('comment/', '')
        elsif l.href =~ /coupon\/d+/
          l.href.to_s
        end
      }.compact.uniq   
    end              
    
    def pages_links   
      @doc.links.detect{|l| l.text == 'Recent Deals'}.href
    end
    
    def capture_paginated_deal_links
      get(pages_links)
      @doc.links.collect{|link| link.href if link.href =~ /^\/coupon\/\d+$/}.compact.uniq
    end         
    
    def error_page?(url)
      url =~ /.com\/$/
    end
        
    def buyers_count
      @doc.search("div[@id='dealTotalBought']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
    end                                                                                                   
    
    def detect_deal_division                                 
      link = @doc.search("a[@class='country_selected']").text.downcase
      find_or_create_division(link)
    end
    

  end # OpenTable
end # Snapshooter