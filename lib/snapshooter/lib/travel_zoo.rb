module Snapshooter
  class TravelZoo < Base   
    def initialize(site_id)
      site = Site.find(site_id)
      @site_id = site_id
      @base_url = site.base_url
      super
    end  
    
    def get(resource, options = {})
      url = options[:full_path] ? resource : (base_url + resource)
      begin                             
        @mecha ||= Mechanize.new
        @doc = @mecha.get(url)        
      rescue OpenURI::HTTPError => e
        log e.message
      end
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
    
    def site
      @site ||= Site.find(@site_id)
    end
    
    def deal_links
      @doc.search("a[@class='seeDetailsBtn']").map{|link| link['href'] if link['href'] =~ %r[/local-deals/deal/(\d+)]  }.compact
    end    
    
    def pages_links   
      @doc.search("a[@class='dealPagerPagingNumbers']").map{|link| link['href'].scan(/doPostBack\('(.*)',''\)/).flatten.first }.compact            
    end
    
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
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      get(deal.permalink, :full_path => true)
      buyers_count
    end
    
    def buyers_count
      @doc.search("span[@id='ctl00_Main_LabelBought']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
    end
    
    def crawl_new_deals!
      # Find the site
      puts "#{site.name} is crawling"
      
      divisions.map do |dhash|
        division_url = dhash[:url]        
        options = {}
        options[:full_path] = division_url =~ /^http(.+)/i
        
        
        # Find the division
        @division = site.divisions.find_or_initialize_by_name(dhash[:name])
        @division.source = site.source_name
        @division.url = options[:full_path] ? division_url : (base_url + division_url)
        @division.save
        
        get(division_url, options)
        links = deal_links
        links = links.concat capture_paginated_deal_links
        links.map do |deal_link|
          puts "Ping: #{deal_link}"
          options[:full_path] = (deal_link =~ /^http(.+)/i) ? true : false
          get(deal_link, options)
          
          travel_zoo_deal = Snapshooter::TravelZoo::Deal.new(@doc, deal_link, @site_id, options)
          
          save_deal!(travel_zoo_deal.to_hash)
        end
      end           
    end
  
    class Deal
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
    
      def lat              
        @lat ||= @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[1].to_f
      end
    
      def lng     
        @lng ||= @doc.parser.to_s.match(%r[addMarker\(([-\d\.]+), ([-\d\.]+)])[2].to_f
      end         
      
      def site
        @site ||= Site.find(@site_id)
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
    
      def permalink
        @permalink ||= @options[:full_path] ? @deal_link : (base_url + @deal_link)
      end
    
      def telephone   
        country = site.source_name.scan /uk/
        @telephone ||= Snapshooter::Base.new.split_address_telephone(raw_address, country).try(:last)
      end
      
      def sold_out?
        @sold_out ||= false
      end    
      
      def site_id
        @site_id# || Site.find_by_source_name("travel_zoo").id
      end     
      
      def buyers_count
        @doc.search("span[@id='ctl00_Main_LabelBought']").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
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