module TravelZooCommon
  extend ActiveSupport::Concern
  
  included do
    html_selector :title,               '#ctl00_Main_LabelDealTitle'
    html_selector :buyers_count,        '#ctl00_Main_LabelBought',    :type => :number
    html_selector :price,               '#ctl00_Main_OurPrice',       :type => :number
    html_selector :original_price,      '#ctl00_Main_PriceValue',     :type => :number
  end
  
  # rip the lat/lon out of the google maps JS
  def location
    return unless deal_exists?
    
    doc.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1, 2]
  end
  
  def deal_status
    if text_from_selector('#ctl00_Main_TimeLeft').present?
      :active
    elsif text_from_selector('#ctl00_Main_PanelExpiredDeal').present?
      :closed
    end
  end
end

class TravelZoo < AutoIdImporter
  include TravelZooCommon
  
  def base_url
    "http://www.travelzoo.com/local-deals/deal/"
  end
end

class TravelZooUk < AutoIdImporter
  include TravelZooCommon
  
  def base_url
    "http://www.travelzoo.com/uk/local-deals/deal/"
  end
end