class Yipit

  def self.get_yipit_by_phone(phone)
    data = {}
    begin
      yipit_key = CATEGORIES_API['yipit']['key']
      json = RestClient.get "http://api.yipit.com/v1/deals/?key=#{yipit_key}&phone=#{phone}"
      data = JSON.parse(json)['response']
    rescue => e
      HoptoadNotifier.notify(e)
      "YIPIT category search failed: #{e.message}"
    end   
    data
  end
  
  # Try to retrieve categories for a deal
  def self.get_categories(deal)
    yipit_categories = []
    if deal.telephone
      phone = strip_phone(deal.telephone)
      
      data = get_yipit_by_phone(phone)
      data['deals'].map{|d|           
        locations = d['business']['locations']
        if !locations.empty?                  
          loc_phone = locations.first['phone']
          if loc_phone && strip_phone(loc_phone) == phone
            yipit_categories << d['tags'].collect{ |t| t['name'] }
          end
        end
      } if data['deals']
    end
    deal.categories = yipit_categories.flatten.compact
    yipit_categories
  end
  
  private
    def self.strip_phone(phone)
      phone.gsub(/\+1|\s|-|\.|\(|\)/,'') if phone
    end
end