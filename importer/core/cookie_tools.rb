module CookieTools
  extend ActiveSupport::Concern
  
  module ClassMethods
    def agent
      @agent ||= begin
        puts "[#{to_s}] loading cookie from #{cookie_url}"
        agent = Mechanize.new
        agent.get(cookie_url)
        agent
      end
    end
    
    def load_url(url)
      begin
        puts "[#{to_s}] loading with cookie: #{url}"
        agent.get(url).body
      rescue Timeout::Error, IOError, Net::HTTPBadResponse, Zlib::DataError => e
        Rails.logger.info "[#{to_s}] ERROR loading #{url} - " + e.inspect
        puts "[#{to_s}] ERROR loading #{url} - " + e.inspect
      end
    end
  end
end