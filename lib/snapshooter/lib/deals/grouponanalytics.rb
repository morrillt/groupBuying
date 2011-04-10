module Snapshooter
  class Grouponanalytics
    class Deal < BaseDeal

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
        # debugger
        snapshots_table = @doc.search("table")[2].children[1].children
        snapshots_table[1..-1].each {|row|      
          c = row.children
          snapshots << {:created_at => c[0].text, :buyers_count => c[4].text}
        }
        debugger
        puts '1'
      end                   

      def to_hash
        snaps = snapshots
        get(permalink)
        super.merge({:snapshots => snaps})
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