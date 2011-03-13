class LivingSocialCrawler < ScrapingCrawler
  include CookieTools
  
  class << self
    def cookie_url
      "http://livingsocial.com/?msc_id=1"
    end
    
    def base_url
      "http://deals.livingsocial.com"
    end
    
    def division_list_url
      "#{base_url}/cities/deals/more_deals"
    end
  
    def division_link_regex
      %r[/(cities/[\w-]+)]
    end
    
    def possible_division_links
      divisions_doc.search('.cities-list a')
    end
  end
  
  def possible_deal_links
    doc.search('.deal-buy-box a')
  end
  
  def deal_link_regex
    %r[/deals/(\d+)]
  end
  
  def url
    @url ||= [base_url, division.url_part, 'today'].join('/')
  end
end