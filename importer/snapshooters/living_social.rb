class LivingSocialSnapshooter < HTMLSnapshooter
  html_selector :title,           '.deal-title'
  html_selector :price,           '#deal-buy-box .deal-price',          :type => :number
  html_selector :discount,        '.value',                             :type => :number
  html_selector :buyers_count,    '#deal-buy-box .purchased .value',    :type => :number
  
  def deal_status
    if text_from_selector('#deal-buy-box .buy-now-active').present?
      :active
    elsif text_from_selector('#deal-buy-box .buy-now-over').present?
      :closed
    end
  end
  
  def base_url
    "http://livingsocial.com/deals/"
  end
  
  # TODO: extract this into a module if we get any other sites using cookies
  class << self
    def agent
      @@agent ||= begin
        puts "loading LivingSocial cookie"
        agent = Mechanize.new
        agent.get("http://livingsocial.com/?msc_id=1")
        agent
      end
    end
  end
  
  def load_url
    @load_url ||= self.class.agent.get(url).body rescue nil
  end
  
  def existence_check
    begin
      load_url
    rescue Net::HTTPBadResponse, Mechanize::ResponseCodeError => e
      if e.message == "404 => Net::HTTPNotFound" || e.message =~ /wrong status line/
        return false
      else
        raise e
      end
    end
    
    return true
  end
end