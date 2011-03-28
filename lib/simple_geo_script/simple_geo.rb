require 'simple_geo'
require 'yaml'

module SimpleGeo
  #SimpleGeo::SimpleGeoCollector.new
  class SimpleGeoCollector
    
    def search hash
      authenticate
      address = hash[:address]
      options = {'radius' => 0.1}
      places = (SimpleGeo::Client.get_places_by_address(address,
                                                        options))
      site = 0
      # puts "my address #{hash[:address]}"
      # puts "total places found: #{places[:total]}"
      if places[:total]>0
        features = places[:features]
        for f in features
          f_address = f[:properties][:address]
          # puts "feature address #{f_address}"
          comp = f_address <=> address
          case comp
            when 0
            site += 1
            when 1
            site += 1 if f_address.include?address
            when -1
            site += 1 if address.include?f_address
          end
        end
      end
      # puts "returning #{site}"
      return site
    end
    
    def parsing deal
      hash = { }
      split = deal.raw_address.split ','
      hash[:address] = split.first
      # hash[:state] = split.last
      # hash[:zip_code] = deal.telephone.slice(0,5)
      # hash[:phone] = deal.telephone.slice(deal.telephone.length-5,deal.telephone.length).gsub(/[-]/,' ')
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
