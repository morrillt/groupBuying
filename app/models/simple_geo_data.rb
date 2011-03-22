require 'simple_geo'
require 'yaml'
class SimpleGeoData < ActiveRecord::Base

  belongs_to :deals
  
  def search
    testing_geo
    address = "41 Decatur St, San Francisco, CA"
    phone = "+1 888 397 8423"
    places = SimpleGeo::Client.get_places(37.772445, -122.405913)
    context = SimpleGeo::Client.get_context(37.772445,-122.405913)
    # for p in places do
    #   site = p if phone.eql?p[:properties][:phone]
    # end
    # coords = site[:geometry][:coordinates]
    # context = SimpleGeo::Client.get_context(coords.last,coords.first)

    context
    
  end

  private
  def testing_geo
    tokens = YAML::load(File.open("#{RAILS_ROOT}/config/simplegeo.yml"))
    SimpleGeo::Client.set_credentials(tokens['token'],tokens['secret_token'])
  end

end
