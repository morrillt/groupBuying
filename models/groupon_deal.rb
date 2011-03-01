class GrouponDeal < ActiveRecord::Base
  set_table_name "groupon"

  scope :active, where(:status => true)
  scope :closed, where(:status => false)
  scope :today, where(:datadate => Date.today)

  def self.unique
    find_by_sql("SELECT DISTINCT(deal_id), count, pricetext FROM groupon GROUP BY deal_id ORDER BY time")
  end

  def self.num_coupons(range)
    self.send(range).map(&:count).inject(0) { |sum, n| sum += n.to_i }
  end

  def self.spent(range)
    self.send(range).inject(0) { |sum, deal| sum +=  deal.pricetext.to_i * deal.count.to_i }
  end

  def self.average_revenue(range)
    spent(range) / self.send(range).count
  end

  def self.num_zip_codes
    find_by_sql("SELECT DISTINCT(location) FROM groupon").count
  end

end
