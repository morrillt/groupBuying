module Snapshooter
  class Homerun < Base
    def initialize
      @base_url = "http://homerun.com"
      super
    end
    
    def divisions
      return @divisions unless @divisions.empty?
      get("/local")
       # todo returing nil added || []
      @doc.search("li a").map{|link| [link.text, link['href']] }.compact || []
    end
    
    def deal_links
      @doc.search("div[@class='buy-buttons'] a").map{|link| 
        link['href'] if link['href'] =~ %r[\/deal/([-\w]+)] 
      }.compact.map{|url| url.gsub(/\/get\?buy_button=true/,'') }.uniq!
    end
    
    # Returns the current purchase count of a given deal
    def capture_deal(deal)
      get(deal.permalink, :full_path => true)
      @doc.to_s.scan(/\d+ bought\./).try(:first).to_i
    end
    
    def crawl_new_deals!
      super
      # Find the site
      site     = Site.find_by_source_name("homerun")
      
      divisions.map do |division_name, division_path|        
        # Find the division
        @division = site.divisions.find_or_initialize_by_name(division_name)
        @division.name, @division.url = division_name, division_path
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
          
          
          attributes = {}
          attributes[:name]                 = @doc.search("div[@class='title rockwell']").first.text
          attributes[:sale_price]           = @doc.search("a[@class='buy-button']").first.text.gsub(/[^0-9]/,'').to_f
          attributes[:actual_price]         = @doc.search("span[@class='econ rockwell']").first.text.gsub(/[^0-9]/,'').to_f
          attributes[:expires_at]           = expires_at
          attributes[:permalink]            = options[:full_path] ? deal_link : (base_url + deal_link)
          attributes[:site_id]              = site.id
          attributes[:division]             = @division
          
          save_deal!(attributes)
          
        end
      end
      
    end
  end
end