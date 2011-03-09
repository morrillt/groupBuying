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
  
  def doc
    @doc ||= begin
      json = open("http://api.groupon.com/v2/deals/#{deal_id}.json?client_id=#{Groupon.api_key}").read
      hash = JSON.parse(json)
      Hashie::Mash.new(hash).deal
    end
  end
  
  def url
    doc.dealUrl
  end
  
  def attrs
    {
      :title        => doc.title,
      :url          => doc.dealUrl,
      :price        => doc.options.first.price.amount,
      :value        => doc.options.first.discount.amount,
      :buyers_count => doc.deal.soldQuantity,
      :active       => doc.deal.status,
    }
  end
end