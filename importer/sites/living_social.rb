class LivingSocial < AutoIdImporter
  html_selector :title,               '.deal-title'
  html_selector :price_text,          '#deal-buy-box .deal-price'
  html_selector :discount_text,       '.value'
  html_selector :buyers_count_text,   '#deal-buy-box .purchased .value'
  
  def base_url
    "http://livingsocial.com/deals/"
  end
  
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
    @load_url ||= self.class.agent.get(url).body
  end
  
  def exists?
    begin
      load_url
    rescue Mechanize::ResponseCodeError => e
      if e.message == "404 => Net::HTTPNotFound"
        return false
      else
        raise e
      end
    end
    
    return true
  end
end