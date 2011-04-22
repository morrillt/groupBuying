module Snapshooter
  class Homerun
    
    # MockUp deal class for Homerun
    class Deal < BaseDeal
      def initialize(doc, deal_link, site_id, options = {})
        @doc = doc
        @deal_link = deal_link                
        @site_id = site_id
        @options = options
      end

    end
  end
end
      