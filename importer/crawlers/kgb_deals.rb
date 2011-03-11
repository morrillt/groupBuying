class KgbDealsCrawler < ScrapingCrawler
  class << self
    def base_url
      "http://www.kgbdeals.com"
    end
  
    def division_list_url
      "#{base_url}/sitemap"
    end
  
    def division_link_regex
      %r[/sitemap/(.*)]
    end
    
    def possible_division_links
      divisions_doc.search('.city a')
    end
  end
  
  def url
    @url ||= base_url + "/sitemap/#{division.url_part}"
  end
  
  def possible_deal_links
    doc.search('a.deal')
  end
  
  def deal_link_regex
    %r[http://www.kgbdeals.com/[\w-]+/deals/(\d+)/]
  end
end