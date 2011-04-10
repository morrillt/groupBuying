module Snapshooter     
  # Class handle logic to fill out one site data from outside source e.g. grouponanalytics.com
  # Rewrite methods in subclasses if custom behavior needed
  class Outsider < Crawler
    
    def crawl_deal(url, options)
      puts "Ping: #{url}"
      detect_absolute_path(url, options)

      get(url, options) do  
        unless error_page? @doc.uri.to_s
          deal = self.class::Deal.new(@doc, url, @site_id, options)
          save_deal!(deal.to_hash)
        else
          puts "Failed to get #{url}. Error page"
        end
      end
    end    
  
  end
end

