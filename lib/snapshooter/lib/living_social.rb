module Snapshooter
  class LivingSocial < Crawler   
    DIVISION_LIMIT = 30
    DEAL_LIMIT = 150
    
    def crawl_new_deals!(range = nil)
      puts "#{self.class.to_s} is crawling"
      division_links = divisions    
      division_range = range && range[1] != 0 ? division_links[range[0]..range[1]] : division_links

      deals = division_range.collect do |dhash|
        puts "Division: #{dhash[:url]}"
        options = {}
        div_url, div_name = dhash[:url], dhash[:name]        
                                                     
        find_or_create_division(div_name, div_url)
        crawl_division(div_url)        
      end.flatten  
      options = {}
      
      deals = deals.collect{|d| base_url + d}
      detect_absolute_path(deals.first, options)
      deals = deals - site.deals.collect(&:permalink)
      
      total = deals.count
      num = 0
      deals.map do |deal_link|  
        @crawler_job.at(num, total) if @crawler_job
        num += 1
        # Profiler__::start_profile
        crawl_deal(deal_link, options)
        # Profiler__::stop_profile
        # Profiler__::print_profile($stderr)
      end         
    end
              
    def crawl_division(url)   
      options = {}
      detect_absolute_path(url, options)
      get(url, options)
      full_deal_links
    end
    
    def crawl_deal(url, options)
      puts "Ping: #{url}"
      detect_absolute_path(url, options)
      get(url, options) do  
        unless error_page? @doc.uri.to_s
          deal = self.class::Deal.new(@doc, url, @site_id, options)
          save_deal!(deal.to_hash, detect_deal_division(options[:old_deals]))
        else
          puts "Failed to get #{url}. Error page"
        end
      end
    end    
    
    def error_page?(url)       
      @doc.search("ul[@class='deal-info']").first.nil? && @doc.search("ul[@class='clearfix deal-info']").first.nil?
    end    
    
    
    def divisions
      return @divisions unless @divisions.empty?
      get("/cities")         
      @doc.links.map{|link|
        if link.href =~ %r[/cities/\d+[a-z\-]*$] || link.href =~ %r[escapes.livingsocial.com]
          @divisions << { :url => link.href, :name => link.text } 
        end
      }         
      @divisions
    end  
        
    def deal_links
      @doc.links.collect{|link| 
        if link.href =~ %r[/deals/\d+(.*)]
          link.href.scan(%r[(.*/deals/\d+).*]).flatten.first 
        end
      }.flatten.compact.uniq
    end   
    
    def pages_links   
      @doc.links.collect{ |link| 
        if link.href =~ %r[/deals/past] || link.href =~ %r[/more_deals]
          link.href 
        end
      }.compact
    end
    
    def capture_paginated_deal_links      
      pages_links.collect{ |page|   
        get(page)
        deal_links
      }.flatten
    end
        
    def buyers_count    
      @doc.parser.search("li.purchased .value").text.gsub(Snapshooter::Base::PRICE_REGEX,'').to_i
    end             
         
    def find_or_create_division(name, url = nil)
      options = {}
      detect_absolute_path(url, options)
      # Find the division
      @division = site.divisions.find_or_initialize_by_name(name)
      @division.source = site.source_name
      if url
        @division.url = options[:full_path] ? url : (base_url + url)
      end
      @division.save
    end 
    
    
    def detect_deal_division(old_deals = false)
      # Detect deal if escapes division
      if @doc.uri.to_s =~ /escapes\.livingsocial\.com/
        div = site.divisions.find_or_initialize_by_name("Escapes")
        if div.new_record?
          div.source = site.source_name
          div.url = 'http://escapes.livingsocial.com/deals'
          div.save
          return div
        else
          return div
        end
      elsif old_deals
        div_name = @doc.search("a[@class='market']").first.text
        find_or_create_division(div_name)
        @division
      end  
    end
             

    # Overwrite to click through first box
    def get(resource, options = {})
      url = options[:full_path] ? resource : (@base_url + resource)
      begin
        @doc = @mecha.get(url)
        
        # Clicking through first box with city select
        if @doc.links.first.text == "I'm already a subscriber, skip"
          @doc = @doc.links.first.click
          @doc = @mecha.get(url)
        end
        yield if block_given?
      rescue OpenURI::HTTPError => e
        HoptoadNotifier.notify(e)
        log e.message
      rescue Mechanize::ResponseCodeError => e
        HoptoadNotifier.notify(e)
        log e.message
      end
    end

  end # LivingSocial
end # Snapshooter