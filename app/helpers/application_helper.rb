module ApplicationHelper
  def sites_thumb(site, size="small")
    file= ""
    case site
    when "groupon"
      file= "groupon_30x30.png" if size=="small"
      file= "groupon_50x50.png" if size=="medium"
    when "opentable"
      file= "opentable_30x30.png" if size=="small"
      file= "opentable_50x50.png" if size=="medium"
    when "kgb_deals"
      file= "kgb_deals_30x30.png" if size=="small"
      file= "kgb_deals_50x50.png" if size=="medium"
    when "travel_zoo"
      file= "travelzoo_30x30.png" if size=="small"
      file= "travelzoo_50x50.png" if size=="medium"
    when "living_social"
      file= "livingsocial_30x30.png" if size=="small"
      file= "livingsocial_50x50.png" if size=="medium"
    else
      file= "livingsocial_50x50.png" if size=="medium"
      file= "livingsocial_30x30.png" if size=="small"
    end
    "/images/site-icons/#{file}"
  end

  def random_digits
    rand(100000).to_f/100000
  end

  def random_digits_nyc
    lat= rand(100000)
    while(lat < 68333 || lat > 78333)
      lat= rand(100000)
    end
    lat= lat.to_f/100000
    lng= rand(100000)
    while(lng < 75000 || lat > 91667)
      lng= rand(100000)
    end
    lng= lng.to_f/100000
    return [40.to_f+lat,-73.to_f-lng]
  end   
  
  def price(entity, method, *args)
    currency = if entity.respond_to? :site
      entity.site.currency 
      else
        entity.try(:currency)
      end                 
    p = entity.send(method, *args)
    p = p.to_i if p.to_i == p
    number_to_currency(p, :unit => currency_symbol(currency))
  end                                                        
  
  def sprice(price, currency = 0)
    number_to_currency(price, :unit => currency_symbol(currency))
  end
  
  def d(date)
    date.to_s(:short) if date
    # l date if date
  end
  
  def dt(datetime)
    # datetime.strftime('%b %d, %Y %I:%M %p') if datetime
    l datetime if datetime
  end       
  
  def currency_symbol(currency)
    case currency
      when 1
        '£'
      else 0
        '$'
      end
  end
  
end
