class HomeRunSnapshooter < HTMLSnapshooter
  html_selector :title,           '.content .title'
  html_selector :original_price,  '.first td.val .econ',    :type => :number
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
end