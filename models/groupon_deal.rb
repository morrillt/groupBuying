require 'active_record'

class GrouponDeal < ActiveRecord::Base
  set_table_name "groupon"

  attr_reader :deals

  scope :active, lambda { unique.where(:status   => true ) }
  scope :closed, lambda { unique.where(:status   => false) }
  scope :yesterday,  lambda { unique.where(:datadate => Date.today - 1.days) }
  scope :today,  lambda { unique.where(:datadate => Date.today) }
  scope :zip_codes, select("DISTINCT(location)")
  scope :unique, select("DISTINCT(deal_id), groupon.count, pricetext, datadate, location, status").order("time").group("deal_id")
  scope :by_deal, lambda { |id| select("datadate, time, count, location, deal_id").where(:deal_id => id).order("datadate DESC, time DESC") }

  def self.num_coupons(range=:unique)
    self.send(range).map(&:count).inject(0) { |sum, n| sum += n.to_i }
  end

  def self.spent(range=:unique)
    self.send(range).inject(0) { |sum, deal| sum +=  deal.pricetext.to_i * deal.count.to_i }
  end

  def self.average_revenue(range=:unique)
    self.spent(range) / self.send(range).length
  end

  def hotness_index
    @deals ||= GrouponDeal.by_deal(deal_id)
    present = @deals.first.count.to_i
    past = @deals.last.count.to_f
    return 0 if present == 0 or past == 0
    ((present - past) / past) * 100
  end
end
