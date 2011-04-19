module Snapshooter
  class KgbDeals
    class Deal < BaseDeal
  
    def name
      xpath("div[@class='deal_title'] h2").first.try(:text)
    end
    
    def sale_price
      xpath("div[@class='buy_link'] a").first.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
    end
    
    def actual_price
      xpath("div[@id='deal_basic_left'] dl dd").first.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
    end
    
    def raw_address
      raw_address = ""
      raw_address << @doc.search("div[@id='deal_more_left'] ul li").first.try(:text)
      raw_address << " "
      raw_address << @doc.search("div[@id='deal_more_left'] ul li")[2].try(:text)
      raw_address << " "
      raw_address << @doc.search("div[@id='deal_more_left'] ul li")[3].try(:text)
    end
    
    def telephone 
      telephone = @doc.search("div[@id='deal_more_left'] ul li")[4].try(:text)
    end
    
    def site
    end      
    
    def expires_at
      ex_time = @doc.search("dl[@class='expires'] dd").first.attributes
      expires_at = Time.parse("#{ex_time['ey'].value}/#{ex_time['em'].value}/#{ex_time['ed'].value} #{ex_time['eh'].value}:#{ex_time['ei'].value}:#{ex_time['es'].value}")
    end
                    
    def buyers_count
      xpath("h4").first.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
    end
    
    def lat              
      # @lat = @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1].to_f
    end
      
    def lng     
      # @lng = @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[2].to_f
    end         
    
      
    def to_hash
      {
        :name => name,
        :site_id => site_id,
        :sale_price => sale_price,
        :actual_price => actual_price,
        :raw_address => raw_address,
        :lat => lat,
        :lng => lng,
        :expires_at => expires_at,
        :permalink => permalink,
        :telephone => telephone,
        :max_sold_count => buyers_count
      }
    end
    
    end
  end   
end
