module Snapshooter
  class LivingSocial
    class Deal < BaseDeal
      def initialize(doc, deal_link, site_id, options = {})
        @doc = doc
        @deal_link = deal_link                
        @site_id = site_id
        @options = options
      end

      def name
        @name ||= @doc.parser.search("div[@class='deal-title']").try(:text).gsub("\n", '').gsub(/\s+/, ' ')
      end

      def sale_price
        @sale_price = @doc.parser.search("div[@class='deal-price deal-price-lg']").try(:text).to_s.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
        if @sale_price == 0
          @sale_price = @doc.parser.search("div[@class='deal-price deal-price-sm']").try(:text).to_s.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f 
        end    
        @sale_price
      end

      def actual_price
        original_price = @doc.parser.css("p.original-price del").first
        if original_price
          @actual_price = original_price.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
        else
          savings = @doc.parser.css("ul.clearfix.deal-info li div.value").first.text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
          if savings > 0 && sale_price > 0
            @actual_price = sale_price / (1 - (savings * 0.01))
          end
        end
        @actual_price.try(:round)
      end

      def raw_address
        @raw_address = @doc.parser.search("div.meta span.street_1").try(:text)
      end       

      def telephone   
        @telephone = @doc.parser.search("div.meta span.phone").try(:text)
      end

      def lat                                                           
        @lat = @doc.parser.to_s.match(%r["coordinate":\[([-\d\.]+),([-\d\.]+)\]])
        @lat[1].to_f if @lat
      end

      def lng
        @lng = @doc.parser.to_s.match(%r["coordinate":\[([-\d\.]+),([-\d\.]+)\]])
        @lat[2].to_f if @lng
      end         

      def buyers_count      
        @doc.parser.search("li.purchased .value").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
      end

      def expires_at
        return @time_left if @time_left
        # Parse javascript counter
        @time_left = Time.now
        JSON.parse(@doc.parser.text.scan(%r[counter\((.*)\)]).flatten.first).map{|v,k|
          v = v.to_i
          case k 
            when 'd'
              @time_left += v.days
            when 'h'
              @time_left += v.hours
            when 'm'
              @time_left += v.minutes
            when 's'
              @time_left += v.seconds
          end
        }
        @time_left
      end

    end   
  end
end