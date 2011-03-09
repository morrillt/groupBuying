class HomeRun < UrlImporter
  html_selector :title,           '.content .title'
  html_selector :original_price,           '.first td.val .econ',    :type => :number
  html_selector :discount,        '.middle td.val .econ',   :type => :number
  
  # e.g. 73/74 sold
  def buyers_count
    @buyers_count ||= begin
      txt = doc.search('.rockwell').inner_text[/((\d+)\/)?(\d+)\s?(bought|sold)/]
      txt.try(:to_i)
    end
  end
  
  def deal_status
    text_from_selector('.ended').present? ? :closed : :active
  end
  
  def base_url
    "http://homerun.com/deal/"
  end
  
  def self.areas
    %w(daily-steal city-sampler private-reserve hot-minute)
  end
  
  def self.find_new_deals(&block)
    divisions_for_import.each do |division|
      puts "scanning #{division.name}"
      areas.each do |area|
        url = "http://homerun.com/#{division.url_part}/#{area}"
        doc = Nokogiri::HTML(open(url))
        doc.search('.buy-buttons a').map{|a| a['href'].match(%r[\/deal/([-\w]+)])[1] }.each do |deal_id|
          yield new(deal_id)
        end
      end
      
      division.update_attribute(:last_checked_at, Time.now)
    end
  end
end