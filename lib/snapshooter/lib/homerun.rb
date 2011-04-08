module Snapshooter
  class Homerun < Crawler
    def divisions
      return @divisions unless @divisions.empty?
      get("/local")
       # todo returing nil added || []
      @divisions = {}
      @doc.search("div[@class='vertical-list'] ul li a").map{ |link|  
        if link['href'][0..4] != "/deal"
          @divisions[link.text] = link['href']
        end
      } || {}
    end
    
    def deal_links
      @doc.search("div[@class='buy-buttons'] a").map{|link| 
        link['href'] if link['href'] =~ %r[\/deal/([-\w]+)] 
      }.compact.map{|url| url.gsub(/\/get\?buy_button=true/,'') }.uniq
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      get(deal.permalink, :full_path => true)
      buyers_count
    end      
        
    # Capture buyers_count
    def buyers_count
      @doc.to_s.scan(/\d+ bought\./).try(:first).to_i
    end
    
    def crawl_new_deals!
      # Find the site
      @site     = Site.find_by_source_name("homerun")
      divisions.map do |division_name, division_path|
        # Find the division
        @division = @site.divisions.find_or_initialize_by_name(division_name)
        @division.name, @division.url = division_name, division_path
        @division.source = "homerun"
        @division.save
        get(@division.url)
        deal_links.map do |deal_link|
          options = {:full_path => deal_link =~ /^http(.+)/i ? true : false}
          puts "Ping: #{deal_link}"
          get(deal_link, options)
          
          # Parse time left
          time_left = @doc.search("div[@class='counter'] big").map(&:text).map(&:to_i)
          
          expires_at = time_left[0].days.from_now + time_left[1].hours +  time_left[2].minutes + time_left[3].seconds
          
          # Skip deal if no expiration time present
          if time_left.empty? || time_left.size < 4
            log "Sold out"
            next
          end
          
          # Skip deal if expired
          if expires_at <= Time.now
            log "Expired"
            next
          end
                    
          save_deal!({
            :name => @doc.search("div[@class='title rockwell']").first.try(:text).to_s.gsub("\n", ''),
            :sale_price => @doc.search("a[@class='buy-button']").first.try(:text).to_s.gsub(Snapshooter::Base::PRICE_REGEX,'').to_f,
            :actual_price => @doc.search("span[@class='econ rockwell']").first.try(:text).to_s.gsub(/[^0-9]/,'').to_f,
            :expires_at => expires_at,
            :permalink => options[:full_path] ? deal_link : (base_url + deal_link),
            :site => @site,
            :division => @division,
            :expires_at => expires_at,
            :raw_address => "",
            :telephone => "",
            :active => true,
            :max_sold_count => buyers_count
          })          
        end
      end
      
    end
  end
end