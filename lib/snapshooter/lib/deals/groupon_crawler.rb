module Snapshooter
  class GrouponCrawler
    class Deal < BaseDeal
      def divisions
        @site.divisions
      end

      def name  
        @doc.search("div[@class='control_title'] h2 a").text.gsub(/\s+/, ' ').strip
      end

      def sale_price
        @doc.parser.css("div#amount").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end

      def actual_price               
        @doc.search("div[@id='deal_discount']").children[1].children[2].text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end

      def raw_address                  
        address = @doc.parser.css("div.address p")
        if address.children[0] and address.children[2]
          (address.children[0].text + address.children[2].text).gsub(/\s+/, ' ').strip
        end
      end

      def expires_at
      end

      def buyers_count
        @doc.parser.css("tr.sum .td.left span.number").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i || 0
      end

      def lat              
        # @lat = @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1].to_f
      end

      def lng     
        # @lng = @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[2].to_f
      end         

      def permalink
        @permalink = @options[:full_path] ? @deal_link : (base_url + @deal_link)
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
          :expires_at => 1.days.ago,
          :permalink => permalink,
          :telephone => telephone,
          :max_sold_count => buyers_count
        }
      end                    
      
    end #GrouponCrawler::Deal
  end #GrouponCrawler
end # Snapshooter
