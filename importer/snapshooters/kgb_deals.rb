class KgbDealsSnapshooter < HTMLSnapshooter
  html_selector :title,           '.deal_title h2'
  html_selector :price,           '.buy_link a',              :type => :number
  html_selector :original_price,  '#deal_basic_left/dl/dd',   :type => :number
  html_selector :buyers_count,    '#deal_basic_left/h4',      :type => :number
  html_selector :location,        'a#deal_see_more_back',     :type => :address, :attr => 'deal_map_location'
  
  def deal_status
    text_from_selector('.expires').present? ? :active : :closed
  end
  
  def base_url
    "http://www.kgbdeals.com/deals/deals/"
  end
  
  # do a check based on custom header they send
  # TODO: case-statement/exception handler for these headers
  # e.g. invalid: US_translations_deal_view_invalid_deal_id
  # txt[/US_translations_deal_bought_vocab_person/]... lol?
  def existence_check
    txt = `curl -I #{url} 2>&1`
    ! txt[/CK:.*US_translations_deal_view_invalid_deal_id/]
  end
  
  def active
    # FIXME 'deal_expire_counter'?
    true
  end
end