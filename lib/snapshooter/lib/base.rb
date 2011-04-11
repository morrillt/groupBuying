require 'open-uri'
module Snapshooter

  class Base    
    attr_reader :doc
    TELEPHONE_REGEX = /[0-9]*[\-\(\)]+[0-9\-\(\)]+/
    UK_TELEPHONE_REGEX = /[0-9]{3,5}\s+[0-9]{3,5}\s+[0-9]{3,5}/
    PRICE_REGEX = /[^0-9\.]/
   
    def initialize(source)
      @mecha = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
      @doc = @mecha
    end    
    
    def get(resource, options = {})
      url = options[:full_path] ? resource : (base_url + resource)
      begin
        @doc = @mecha.get(url)
        yield if block_given?
      rescue OpenURI::HTTPError => e
        log e.message
      rescue Mechanize::ResponseCodeError => e
        log e.message
      end
    end
           
    def xpath(path)
      (doc/path) || []
    end
    
    def log(msg)
      unless Rails.env.test?
        pp "#{self.class.to_s} [#{Time.now.to_s}] #{msg}"
      end
    end
    
    def detect_absolute_path(url, options)
      options[:full_path] = (url =~ /^http(.+)/i) ? true : false
    end
              
    
    def self.split_address_telephone(address, country = :usa)
      telephone_regex = unless country == :usa || country.empty?
          self.const_get("#{country}_telephone_regex".upcase)
        else
          TELEPHONE_REGEX
        end
      
      address ||= ''
      match_data = address.match(telephone_regex)
      if match_data
        [address.gsub(telephone_regex, ''), match_data.to_s]
      else
        [address, nil]
      end
    end  
    
    def time_counter_to_expires_at(counter)
      expires = Time.now
      counter.map{|k,v|
        v = v.to_i
        case k 
          when 'd', 'days'
            expires += v.days
          when 'h', 'hours'
            expires += v.hours
          when 'm', 'minutes'
            expires += v.minutes
          when 's', 'seconds'
            expires += v.seconds
        end  
      }
      expires
    end
  end
end