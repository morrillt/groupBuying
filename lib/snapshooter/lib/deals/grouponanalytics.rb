module Snapshooter
  class Grouponanalytics
    class Deal < GrouponCrawler::Deal
      
      def name                     
        el = groupon_deal_element[1]
        el.text if el
      end

      def permalink                                          
        el = groupon_deal_element[1]       
        el[:href] if el
      end 
                                                                       
      def snapshots
        snapshots = []    
        snapshots_table = @doc.search("table")[2].children[1].children
        snapshots_table.each {|row|
          c = row.children
          snapshots << {:created_at => c[0].text, :buyers_count => c[4].text}
        }
        snapshots
      end  

      # Return deal info.
      # first looking for a deal via API, if unsuccessfull, then Crawls site for deal
      def to_hash(division_name, permalink)
        division = Division.find_by_name_and_site_id(division_name, @site_id)
        groupon_deal = GrouponApi.find_at_groupon_by_division_and_permalink(division.site_division_id, permalink)
        # If deal is active and get retrieved by Groupon gem
        if groupon_deal # to_hash for GrouponApi::Deal
          pp 'API'                                       
          GrouponApi::Deal.new(groupon_deal).to_hash(@site_id, division)
        else # If deal isn't active - crawl deal manually by permalink
          pp 'Crawled'
          GrouponCrawler.crawl_deal(permalink, @site_id, division).to_hash
        end        
      end                 

      def lat; end
      def lng; end
      
      private                       
        # return table row
        def groupon_deal_element
          @deal_overview ||= @doc.search("table[@id='deal-overview'] tr td a")
        end
    end   
  end
end