module Snapshooter
  class TravelZoo < Crawler   
    
    def divisions
      return @divisions unless @divisions.empty?
      get("/local-deals")
      @doc.search("li a").map{|link|  
        if link['href'] =~ %r[/local-deals/(.*)/deals]
          @divisions << { :url => link["href"], :name => link.text } 
        end
      }
      @divisions
    end  
                        
    # Captures deal links from current page
    def deal_links
      @doc.search("a[@class='seeDetailsBtn']").map{|link| link['href'] if link['href'] =~ %r[/local-deals/deal/(\d+)]  }.compact
    end    
    
    # Captures pages links
    def pages_links   
      @doc.search("a[@class='dealPagerPagingNumbers']").map{|link| link['href'].scan(/doPostBack\('(.*)',''\)/).flatten.first }.compact            
    end
    
    # Deal links from other pages
    def capture_paginated_deal_links
      pages_links.collect{ |page|   
        # Get page
        form = @doc.form("aspnetForm")
        form.add_field!('__EVENTARGUMENT', '')
        form.add_field!('__EVENTTARGET', page)
        @doc = @mecha.submit(form)
        deal_links
      }.flatten
    end
    
    def error_page?(url)
      url =~ /local-deals\/error/
    end
          
    def buyers_count
      @doc.search("span[@id='ctl00_Main_LabelBought']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
    end      
    
    def detect_deal_division
      link = @doc.search("img[@alt='*']").first.previous_element
      find_or_create_division(link.text, link['href'])
    end 
       
    def update_expires_at
      site.deals.inactive.all.each{|d|
        get(d.permalink, :full_path => true)
        d.expires_at = expires_at
        d.save
      }
    end

  end # TravelZoo
end # Snapshooter