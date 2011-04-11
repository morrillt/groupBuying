module Snapshooter
  class Grouponanalytics < Outsider   
    
    def initialize
      super('groupon')
      @base_url = 'http://www.grouponanalytics.com'
    end
     
    def divisions
      return @divisions unless @divisions.empty?
      get("/cities")
      @doc.links.map{|link|
        if link.href =~ %r[/cities/[\da-z\-]*/deals$]
          @divisions << { :url => link.href, :name => link.text } 
        end
      }                                           
      @divisions
    end  
                        
    # Captures deal links from current page
    def deal_links
      @doc.search("li a").map{|link| 
        if link['href'] =~ %r[/deal/(.*)]
          link['href']
        end
      }.compact
    end    
    
    # Captures pages links
    def pages_links   
      []
    end
    
    # Deal links from other pages
    def capture_paginated_deal_links
      []
    end
                  
    def crawl_deal(url, options)
      puts "Ping: #{url}"
      detect_absolute_path(url, options)
      
      new_deals, new_snapshots = 0, 0
              
      get(url, options) do  
        deal = self.class::Deal.new(@doc, url, @site_id, options)
        # debugger
        deal_snapshots = deal.snapshots
        deal_hash = deal.to_hash(@division.name, deal.permalink)

        if d = ::Deal.find_by_permalink(deal_hash[:permalink])
          # Update???
        else
          new_deals += 1
          d = save_deal!(deal_hash)
        end
        # debugger
        new_snapshots += d.update_snapshots(deal_snapshots)
      end
    end    
    
  

  end
end