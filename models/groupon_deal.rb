require 'active_record'

class GrouponDeal < ActiveRecord::Base
  set_table_name "groupon"

  attr_reader :deals

  scope :active, lambda { unique.where(:status   => true ) }
  scope :closed, lambda { unique.where(:status   => false) }
  scope :yesterday,  lambda { unique.where(:datadate => Date.today - 1.days) }
  scope :today,  lambda { unique.where(:datadate => Date.today) }
  scope :hourly, lambda { today.where("hour(now())=hour(time)") }
  scope :unique, select("DISTINCT(deal_id), groupon.count, pricetext, datadate, location, status, urltext").order("time").group("deal_id")
  scope :by_deal, lambda { |id| select("datadate, time, count, location, deal_id").where(:deal_id => id).where(:status => true).order("datadate DESC, time DESC") }
  scope :by_day, lambda { |day| where(:datadate => day) }

  def self.num_coupons(range=:unique)
    self.send(range).map(&:count).inject(0) { |sum, n| sum += n.to_i }
  end

  def self.hot
    GrouponDeal.find_by_sql("SELECT DISTINCT deal_id, hotindex, urltext, location FROM groupon WHERE status = '1' AND hour(time)=(hour(now())) ORDER BY hotindex DESC LIMIT 10;")
  end

  def self.spent(range=:unique)
    self.send(range).inject(0) { |sum, deal| sum +=  deal.pricetext.to_i * deal.count.to_i }
  end

  def self.average_revenue(range=:unique)
    self.spent(range) / (self.send(range).length + 0.01)
  end

  def self.zipcodes(arr)
    arr.map(&:location).uniq.length
  end

  def self.by_hour(hours)
    find_by_sql("SELECT deal_id, pricetext, time, count, datadate FROM groupon WHERE day(datadate)=(day(now())) AND status='1' AND hour(time)=hour(DATE_SUB(NOW(), INTERVAL #{hours} HOUR));")
  end

  def hotness_index
    @deals ||= GrouponDeal.by_deal(deal_id)
    return 0 if @deals.empty?
    present = @deals.first.count.to_f
    past = @deals.last.count.to_f
    return 0 if present == 0 or past == 0
    GrouponDeal.change(past, present)
  end

  def self.change(past, present)
    value = ((present.to_f - past.to_f) / past.to_f ) * 100
    GrouponDeal.round(value)
  end

  # TODO DRY this up
  def self.chart_data
    daily_data = []
    aggregates = []
    23.times do |i|
      daily_data.unshift GrouponDeal.by_hour(i)
    end

    daily_data.each do |day|
      count = day.count
      average_price = 0
      num_deals = 0
      if count != 0
        average_price = day.map {|x| x.pricetext.to_f}.sum / count
        num_deals = day.map {|x| x.count.to_f}.sum / count
      end

      aggregates << [day.first.time, self.round(count * average_price * num_deals)]
    end
    [aggregates.map(&:first), aggregates.map(&:last)]
  end

  # workaround rounding bug in MRI 1.8.7
  def self.round(num)
    ("%.2f" % num).to_f
  end
end
