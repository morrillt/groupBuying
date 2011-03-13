class OpenTableSnapshooter < HTMLSnapshooter
  html_selector :title,             '#content h1'
  html_selector :price,             '.detailsPageDealInfoPrice',    :type => :number
  html_selector :original_price,    '.origPriceValue',              :type => :number
  html_selector :buyers_count,      '.peoplePurchasedValue',        :type => :number
  html_selector :location,          '.formattedAddress',            :type => :address
  
  def deal_status
    if text_from_selector('.buyButton').present?
      :active
    elsif text_from_selector('.alertMeBtn').present?
      :pending
    elsif text_from_selector('.expiredBtn').present?
      :closed
    else
      :invalid
    end
  end
  
  def base_url
    "http://spotlight.opentable.com/deal/"
  end
end