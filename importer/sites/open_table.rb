class OpenTable < AutoIdImporter
  html_selector :title,         '#content h1'
  html_selector :price,         '.detailsPageDealInfoPrice',    :type => :number
  html_selector :value,         '.origPriceValue',              :type => :number
  html_selector :buyers_count,  '.peoplePurchasedValue',        :type => :number
  html_selector :location,      '.formattedAddress',            :type => :address
  
  def deal_status
    
  end
  
  def base_url
    "http://spotlight.opentable.com/deal/"
  end
  
  def self.find_new_deals(&block)
    divisions_for_import.each do |division|
      autoincrement_filter(division, division.url_part, &block)
    
      division.update_attribute(:last_checked_at, Time.now)
    end
  end
  
  def self.max_failures
    30
  end
end