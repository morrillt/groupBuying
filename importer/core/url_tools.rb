module UrlTools
  extend ActiveSupport::Concern
  
  def parse_url
    self.class.parse_url(url)
  end
  
  def load_url
    @load_url ||= self.class.load_url(url)
  end
  
  module ClassMethods
    def parse_url(url)
      data = load_url(url)
      puts "[#{to_s}] parsing: #{url}"
      puts "-"*80
      puts data
      puts "-"*80
      Nokogiri::HTML(data)
    end

    # simple open-uri URL loading. override where needed
    def load_url(url)
      begin
        puts "[#{to_s}] loading: #{url}"
        open(url).read
      rescue OpenURI::HTTPError, Timeout::Error => e
        Rails.logger.info "[#{to_s}] ERROR loading #{url} - " + e.inspect
        puts "[#{to_s}] ERROR loading #{url} - " + e.inspect
      end
    end
  end
end