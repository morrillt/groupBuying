module Snapshooter
  class TravelZoo < Base   
    def initialize(site_id)
      @site = Site.find(site_id)
      @site_id = site_id
      @base_url = site.base_url
      super
    end  
    
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
      super || url =~ /deals\/$/
    end
    
    def buyers_count
      @doc.search("span[@id='ctl00_Main_LabelBought']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
    end      
    
    def detect_deal_division
      link = @doc.search("img[@alt='*']").first.previous_element
      find_or_create_division(link.text, link['href'])
    end
    
    class Deal < Snapshooter::Base::Deal
      def initialize(doc, deal_link, site_id, options = {})
        @doc = doc
        @deal_link = deal_link                
        @site_id = site_id
        @options = options
      end
    
      def name
        @name ||= @doc.search("span[@id='ctl00_Main_LabelDealTitle']").try(:text)
      end
    
      def sale_price
        @sale_price ||= @doc.search("span[@id='ctl00_Main_OurPrice']").try(:text).to_s.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end
    
      def actual_price
        @actual_price ||= @doc.search("span[@id='ctl00_Main_PriceValue']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f
      end
    
      def raw_address
        @raw_address ||= @doc.search("div[@class='smallMap'] p").children.map{|c| c.try(:text).to_s }.join(" ")
      end
        
      def expires_at
        if @time_left
          return @time_left
        else
          # Parse time left
          @time_left = @doc.search("span[@id='ctl00_Main_TimeLeft']").text.split(",").map!{ |t|
            t.gsub(/[^0-9]/,'').to_i
          }
          if @time_left.empty? || @time_left.size < 3
            @sold_out = true
            return 1.minute.ago
          else
            return(@time_left[0].days.from_now + @time_left[1].hours +  @time_left[2].minutes)
          end
        end
      end
        
      def telephone   
        country = site.source_name.scan /uk/
        @telephone ||= Snapshooter::Base.new.split_address_telephone(raw_address, country).try(:last)
      end
      
      def buyers_count
        @doc.search("span[@id='ctl00_Main_LabelBought']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
      end
      
    end # Deal
    
  end # TravelZoo
end # Snapshooter