class GrouponDeal < ActiveRecord::Base
  set_table_name "groupon"

  scope :active, lambda { unique.where(:status   => true ) }
  scope :closed, lambda { unique.where(:status   => false) }
  scope :today,  lambda { unique.where(:datadate => Date.today) }

  scope :zip_codes, select("DISTINCT(location)")

  case ActiveRecord::Base.connection.adapter_name
  when "PostgreSQL"
    scope :unique, select("DISTINCT ON (groupon.deal_id) groupon.deal_id, groupon.count, pricetext, status")
  else
    scope :unique, select("DISTINCT(deal_id), groupon.count, pricetext, status").group("deal_id").order("time")
  end

  def self.num_coupons(range=:unique)
    self.send(range).map(&:count).inject(0) { |sum, n| sum += n.to_i }
  end

  def self.spent(range=:unique)
    self.send(range).inject(0) { |sum, deal| sum +=  deal.pricetext.to_i * deal.count.to_i }
  end

  def self.average_revenue(range=:unique)
    self.spent(range) / self.send(range).length
  end
end
