module Snapshooter
  class Base      
    
    class Deal
      def initialize(doc, site_id, options = {})
        @doc = doc
        @site_id = site_id
        @options = options
      end
    
      def name
      end
      
      def sale_price
      end
      
      def actual_price
      end
      
      def raw_address
      end
      
      def site
      end      
      
      def expires_at
      end
      
      def telephone   
        @telephone = Snapshooter::Base.split_address_telephone(raw_address).try(:last)
      end
                  
      def buyers_count
      end
      
      def lat              
        @lat = @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1].to_f
      end
    
      def lng     
        @lng = @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[2].to_f
      end         
      
      def permalink
        @permalink = @options[:full_path] ? @deal_link : (base_url + @deal_link)
      end
      
      def site_id
        @site_id
      end   
      
      def site
        @site ||= Site.find(@site_id)
      end   
      
      def base_url
        site.base_url
      end   
      
      def sold_out?
        @sold_out ||= false
      end    
        
      def to_hash
        # debugger
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
