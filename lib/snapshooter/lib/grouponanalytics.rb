module Snapshooter
  class Grouponanalytics < Outsider   
    
    def initialize
      super('groupon')
      @base_url = 'http://www.grouponanalytics.com'
      @new_deals, @new_snapshots = 0, 0
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
        deal_snapshots = deal.snapshots
        d = ::Deal.find_by_permalink(deal.permalink)
        if d # found

        else # not found in db
          deal_hash = deal.to_hash(@division.name, deal.permalink)
          @new_deals += 1
          d = save_deal!(deal_hash)
        end
        
      @new_snapshots += d.update_snapshots(deal_snapshots) if d
      end
    end    
    
    def crawl_division(url)   
      options = {}
      detect_absolute_path(url, options)
      get(url, options)
                    
      full_deal_links.map do |deal_link|  
        crawl_deal(deal_link, options)
      end
      pp "New deals: #{@new_deals}"
      pp "New snapshots: #{@new_snapshots}"
    end  
    
    
  

  end
end