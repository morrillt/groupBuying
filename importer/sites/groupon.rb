class GrouponImporter < BaseImporter
  def self.find_new_deals
    divisions_for_import.each do |division|
      puts "checking #{division.name}"
      Groupon.deals(:division => division.division_id).each do |deal_hashie|
        #puts "yielding #{deal_hashie.inspect}"
        deal = new(deal_hashie.id)
        yield deal
      end
      
      division.update_attribute(:last_checked_at, Time.now)
    end
  end
  
  def parse_doc
    hash = JSON.parse(raw_data)
    Hashie::Mash.new(hash).deal
  end
  
  def raw_data
    @raw_data ||= cached? ? 
      current_snapshot.raw_data : 
      open("http://api.groupon.com/v2/deals/#{deal_id}.json?client_id=#{Groupon.api_key}").read
  end
  
  def base_url
    "http://www.groupon.com/deals/"
  end
  
  def status
    converter = {:open => :active}
    name = doc.status.to_sym
    
    converter[name] || name
  end
  
  def attributes
    @attributes ||= {
      :title            => doc.title,
      :url              => url,
      :price            => doc.options.first.price.amount,
      :original_price   => doc.options.first.discount.amount,
      :buyers_count     => doc.soldQuantity,
      :status           => status,
      :location         => doc.division.values_at('lat', 'lng'),
    }
  end
end