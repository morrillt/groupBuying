module Snapshooter
  class GrouponApi
    class Deal < BaseDeal

      def full_address(groupon_deal)
        full_address = ""
        if groupon_deal.redemptionLocations
          full_address << groupon_deal.redemptionLocations.first.try(:streetAddress1).to_s + "\n"
          full_address << groupon_deal.redemptionLocations.first.try(:streetAddress2).to_s + "\n"
          full_address << groupon_deal.redemptionLocations.first.try(:city).to_s + ", "
          full_address << groupon_deal.redemptionLocations.first.try(:state).to_s + "\n"
          full_address << groupon_deal.redemptionLocations.first.try(:postalCode).to_s
        end
        full_address
      end
      
      def to_hash(groupon_deal, site_id, division) 
        {
          :name           => groupon_deal.title,
          :sale_price     => groupon_deal.price.to_f,
          :actual_price   => groupon_deal.value.to_f,
          :lat            => groupon_deal.division_lat,
          :lng            => groupon_deal.division_lng,
          :expires_at     => groupon_deal.end_date,
          :permalink      => groupon_deal.deal_url,
          :deal_id        => groupon_deal.id,
          :site_id        => site_id,
          :division       => division,
          :raw_address    => full_address(groupon_deal),
          :telephone      => "",
          :active         => true,
          :max_sold_count => groupon_deal.quantity_sold

        }
      end
      
    end
  end
end