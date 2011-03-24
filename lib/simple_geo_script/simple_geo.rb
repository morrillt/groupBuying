require 'simple_geo'
require 'yaml'

module SimpleGeo
  #SimpleGeo::SimpleGeoCollector.new
  class SimpleGeoCollector
    
    def search hash
      authenticate
      address = "#{hash[:address]} #{hash[:zip_code]}"
      options = {'radius' => 0.1}
      places = (SimpleGeo::Client.get_places_by_address(address,
                                                        options))[:features]
      for p in places
        site = p if p[:properties][:phone].include?hash[:phone]
      end
      site
    end
    
    def parsing string
      hash = { }
      address = string.split ','
      hash[:address] = address.first
      temp = address.last.split ' '
      hash[:state] = temp.first
      hash[:zip_code] = temp.last.slice(0,5)
      hash[:phone] = temp.last.slice(temp.last.length-4,temp.last.length).gsub(/[-]/,' ')
      hash    
    end 
    
    def authenticate
      tokens = YAML::load(File.open("#{RAILS_ROOT}/config/simplegeo.yml"))
      SimpleGeo::Client.set_credentials(tokens['token'],tokens['secret_token'])
    end
  end
end
