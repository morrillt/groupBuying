class OpenTableSnapshooter < HTMLSnapshooter
  html_selector :title,             '#content h1'
  html_selector :price,             '.detailsPageDealInfoPrice',    :type => :number
  html_selector :original_price,    '.origPriceValue',              :type => :number
  html_selector :buyers_count,      '.peoplePurchasedValue',        :type => :number
  html_selector :location,          '.formattedAddress',            :type => :address
  
  def deal_status
    :invalid
  end
  
  def base_url
    "http://spotlight.opentable.com/deal/"
  end
end