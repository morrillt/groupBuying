module Snapshooter
  class Weforia < Crawler
    def divisions
      return @divisions unless @divisions.empty?
      get("/")
      @doc.parser.search(".categoryListBoxV2 div").each do |div|
        matches = div.css("a")[0].attributes["onclick"].text.match(/selectCategory\(\d+,\s?'([\w|-]+)'/)
        @divisions << { :url => "#{base_url}/deal/#{matches[1]}", :name => div.css(".categoryNameV2").text } 
      end
      @divisions
    end

    def deal_links
      links = @doc.parser.css('.gbItem').collect do |deal|
        #if deal.css('.listViewGbStatus').count == 0
          link = deal.xpath(".//span[@class='text']/a[@class='link']")[0].attributes["href"].value
          link
        #end
      end.flatten.compact
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

    def buyers_count
      count = @doc.parser.css(".peoplePurchasedValue").text.to_i
      count
    end
  end
end

