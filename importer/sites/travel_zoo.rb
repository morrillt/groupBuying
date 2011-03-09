module TravelZooCommon
  extend ActiveSupport::Concern
  
  included do
    html_selector :title,           '#ctl00_Main_LabelDealTitle'
    html_selector :buyers_count,    '#ctl00_Main_LabelBought',    :type => :number
    html_selector :price,           '#ctl00_Main_OurPrice',       :type => :number
    html_selector :value,           '#ctl00_Main_PriceValue',     :type => :number
    html_selector :location,        '.smallMap p',                :type => :address, :node => :last
  end
  
  def active
    !! text_from_selector('span[id=ctl00_Main_TimeLeft]').blank?
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