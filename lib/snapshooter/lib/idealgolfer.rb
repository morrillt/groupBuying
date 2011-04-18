module Snapshooter
  class IdealGolfer < Crawler
    def divisions
      return @divisions unless @divisions.empty?
      get("/")
      @doc.parser.search(".categoryListBoxV2 div").each do |div|
        matches = div.css("a")[0].attributes["onclick"].text.match(/selectCategory\(\d+,\s?'([\w|-]+)'/)
        @divisions << { :url => "#{base_url}/deal/#{matches[1]}", :name => div.css(".categoryNameV2").text } 
      end
      @divisions
    end

    def crawl_new_deals!(range=nil)
      division_links = divisions    
      division_range = range ? division_links[range[0]..range[1]] : division_links

      deals = division_range.collect do |dhash|
        puts "Division: #{dhash[:url]}"
        options = {}
        div_url, div_name = dhash[:url], dhash[:name]        

        find_or_create_division(div_name, div_url)
        crawl_division(div_url)
      end.flatten
      options = {}
      detect_absolute_path(deals.first, options)
      
      deals.map do |deal_link|
        # Profiler__::start_profile
        crawl_deal(deal_link, options)
        # Profiler__::stop_profile
        # Profiler__::print_profile($stderr)
      end
    end

    def crawl_archived_deals!(range=nil)
      division_links = divisions    
      division_range = range ? division_links[range[0]..range[1]] : division_links

      deals = division_range.collect do |dhash|
        puts "Division: #{dhash[:url]}"
        options = {}
        div_url, div_name = dhash[:url], dhash[:name]        

        find_or_create_division(div_name, div_url)
        crawl_archived_deals_for_division(div_url)
      end.flatten
      options = {}
      detect_absolute_path(deals.first, options)
      
      deals.map do |deal_link|
        # Profiler__::start_profile
        crawl_deal(deal_link, options)
        # Profiler__::stop_profile
        # Profiler__::print_profile($stderr)
      end
    end

    def crawl_deal(url, options)
      get(url, options)
      super(url, options)
    end
    
    def crawl_division(url)
      options = {}
      detect_absolute_path(url, options)
      get(url, options)
      full_deal_links
    end

    def crawl_archived_deals_for_division(url)
      options = {}
      detect_absolute_path(url, options)
      get(url, options)
      all_archive_deal_links
    end

    def all_archive_deal_links
      deal_links.concat(capture_paginated_deal_links).uniq
    end

    def all_archive_deal_links
      @doc.links_with(:text=>/Read More/).collect{|link| link.uri.to_s}.flatten.compact.uniq
    end

    def deal_links
      links = @doc.links_with(:text=>/Today's Deal/).collect{|link| link.uri.to_s}.reject{|link| link == "/"}.flatten.compact.uniq
      puts "Deal links: #{links.inspect}"
      links
    end
    
    def pages_links
      match = @doc.content.match /initPagination\(\d+,\s?(\d+),\s?(\d+),/
      if match
        num_pages = (match[2].to_i/match[1].to_i) + 1
        links = (2..num_pages).collect{|num| "#{@doc.uri}?p=#{num}"}
      end
      links || []
    end

    def capture_paginated_deal_links
      pages_links.collect{ |page|
        get(page, :full_path=>true)
        deal_links
      }.flatten
    end

    def get(resource, options = {})
      url = options[:full_path] ? resource : (@base_url + resource)
      begin
        @doc = @mecha.get(url)

        unless @doc.parser.css("#iDealGolferSplashBackground").nil?
          @doc = @mecha.get(url)
        end
        yield if block_given?
      rescue OpenURI::HTTPError => e
        log e.message
      rescue Mechanize::ResponseCodeError => e
        log e.message
      end
    end
  end
end
