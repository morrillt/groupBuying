module Snapshooter
  class TravelZoo

    class Deal < BaseDeal
      def initialize(doc, deal_link, site_id, options = {})
        @doc = doc
        @deal_link = deal_link                
        @site_id = site_id
        @options = options
      end

      def name
        @name ||= @doc.search("span[@id='ctl00_Main_LabelDealTitle']").try(:text)
      end

      def sale_price
        @sale_price ||= @doc.search("span[@id='ctl00_Main_OurPrice']").try(:text).to_s.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end

      def actual_price
        @actual_price ||= @doc.search("span[@id='ctl00_Main_PriceValue']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end

      def raw_address
        @raw_address ||= @doc.search("div[@class='smallMap'] p").children.map{|c| c.try(:text).to_s }.join(" ")
      end
    
      def expires_at
        if @time_left
          return @time_left
        else
          # Parse time left
          @time_left = @doc.search("span[@id='ctl00_Main_TimeLeft']").text.split(",").map!{ |t|
            t.gsub(/[^0-9]/,'').to_i
          }
          if @time_left.empty? || @time_left.size < 3                 
            expired_text = @doc.search("span[@id='ctl00_Main_ExpiredText']").first
            expired_text ||= @doc.search("div[@class='capReachedSecondLine']").first
            if expired_text    
              return Time.parse(expired_text.text)
            end
          else
            return(@time_left[0].days.from_now + @time_left[1].hours +  @time_left[2].minutes)
          end
        end
      end
    
      def telephone   
        country = site.source_name.scan /uk/
        @telephone ||= Snapshooter::Base.split_address_telephone(raw_address, country).try(:last)
      end
  
      def buyers_count
        @doc.search("span[@id='ctl00_Main_LabelBought']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
      end
  
    end # Deal

  end
end