module Snapshooter
  class IdealGolfer
    class Deal < BaseDeal
      def initialize(doc, deal_link, site_id, options = {})
        @doc = doc
        @deal_link = deal_link                
        @site_id = site_id
        @options = options
      end

      def name
        @name ||= @doc.parser.search("#content h1").text.gsub(@doc.parser.search('#content h1 #todaysDealsText').text, '')
      end

      def sale_price
        @sale_price ||= @doc.parser.search(".detailsPageDealInfoPrice").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
        @sale_price
      end

      def actual_price
        @actual_price ||= @doc.parser.css(".discountBlock .origPriceValue").text.gsub(Snapshooter::Base::PRICE_REGEX, '').to_f
        @actual_price.try(:round)
      end

      def raw_address
        @raw_address ||= @doc.parser.search(".locationAddress .formattedAddress").text
      end

      def telephone   
      end

      def lat                                                           
      end

      def lng
      end         

      def buyers_count
        @buyers_count ||= @doc.parser.css(".peoplePurchasedValue").text.to_i
        @buyers_count
      end

      def expires_at
        return @time_left if @time_left
        time_left_pattern = @doc.parser.text.scan(%r[(((\d)d:)?(\d+)h:(\d+)m(:(\d+)s)?)]).flatten
        return nil if time_left_pattern.size < 7
        time_array = time_left_pattern[2..4] + [time_left_pattern[6]]
        time_array = time_array.collect{|f| f || 0}
        @time_left = Time.now
        @time_left = @time_left + (time_left_pattern[2].to_i * 24*60*60 + time_left_pattern[3].to_i * 60 * 60 + time_left_pattern[4].to_i * 60 + time_left_pattern[6].to_i)
        @time_left
      end
    end
  end
end
