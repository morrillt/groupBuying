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
        agent.get(url).body# rescue nil
      end
    end
  end
end