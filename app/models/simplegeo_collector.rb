class SimplegeoCollector    
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Fields
  field :deal_id, :type => Integer
  field :title, :type => String
  field :permalink, :type => String
  field :business, :type => String
  field :classifiers, :type => Array
  field :phone, :type => String
  field :address, :type => String
  field :tags, :type => Array
  
  def self.authenticate
    tokens = YAML::load(File.open("#{RAILS_ROOT}/config/simplegeo.yml"))
    SimpleGeo::Client.set_credentials(tokens['token'],tokens['secret_token'])
  end
  
  def self.collect
    authenticate
    start_date= Time.now.prev_month.beginning_of_month.to_date
    end_date= Time.now.prev_month.end_of_month.to_date
    deals= Deal.where("expires_at between ? AND ?", start_date, end_date)
    deals_with_geo= Deal.where("expires_at between ? AND ? AND lat IS NOT NULL", start_date, end_date).count
    puts "Total deals: #{deals.count}"
    puts "With geolocation: #{deals_with_geo}"
    deals_matching= []
    deals.each do |d|
      if d.lat
        places= SimpleGeo::Client.get_places(d.lat, d.lng, {'radius' => 0.1})
        deal_phone= d.telephone ? d.telephone.gsub!(/\+1|\s|-|\.|\(|\)/,'') : 0
        places[:features].each do |p|
          simplegeo_phone= p[:properties][:phone] ? p[:properties][:phone].gsub!(/\+1|\s|-|\.|\(|\)/,'') : 1
          if simplegeo_phone == deal_phone
            create({
                     :deal_id => d.deal_id,
                     :title => d.name,
                     :permalink => d.permalink,
                     :business => p[:properties][:name],
                     :classifiers => p[:properties][:classifiers],
                     :phone => p[:properties][:phone],
                     :address => p[:properties][:address],
                     :tags => p[:properties][:tags]
                   })
          end
        end
      else
        # Try phone lookup in Yipit
      end
    end
    puts "Deals matching simplegeo #{deals_matching.size}"
  end
end
