class GrouponSnapshooter < BaseSnapshooter
  def doc
    @doc ||= begin
      hash = JSON.parse(raw_data)
      Hashie::Mash.new(hash).deal
    end
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
  
  def existence_check
    true
  end
  
  def attributes
    @attributes ||= {
      :title            => doc.title,
      :url              => url,
      :price            => doc.options.first.price.amount / 100.0,
      :original_price   => doc.options.first.discount.amount / 100.0,
      :buyers_count     => doc.soldQuantity,
      :status           => status,
      :location         => doc.division.values_at('lat', 'lng'),
    }
  end
end