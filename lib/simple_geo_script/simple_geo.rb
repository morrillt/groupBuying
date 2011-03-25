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
                                                        options))
      if places[:total]>0
        features = places[:features]
        for f in features
          unless hash[:phone].nil? || hash[:address].blank?
            site = f if f[:properties][:phone].include?hash[:phone]
          end
        end
      else
        return nil
      end      
      site
    end
    
    def parsing deal
      hash = { }
      split = deal.raw_address.split ','
      hash[:address] = split.first
      hash[:state] = split.last
      hash[:zip_code] = deal.telephone.slice(0,5)
      hash[:phone] = deal.telephone.slice(deal.telephone.length-5,deal.telephone.length).gsub(/[-]/,' ')
      hash    
    end 
    
    def authenticate
      tokens = YAML::load(File.open("#{RAILS_ROOT}/config/simplegeo.yml"))
      SimpleGeo::Client.set_credentials(tokens['token'],tokens['secret_token'])
    end

    def get_data address
      authenticate
      options = {'radius' => 0.1}
      places = (SimpleGeo::Client.get_places_by_address(address,
                                                        options))
      places
    end
  end
end
