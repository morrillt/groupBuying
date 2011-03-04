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

  def self.by_hour(hours, yesterday=false)
    if yesterday
      day_sql = "day(datadate)=day(DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY))"
    else
      day_sql = "day(datadate)=(day(now()))"
    end
    find_by_sql("SELECT deal_id, pricetext, time, count, datadate FROM groupon WHERE #{day_sql} AND status='1' AND hour(time)'=#{hours}';")
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
    yesterday_hours = []
    hours = Time.now.hour
    if hours < 12
      yesterday_hours = (0..23).to_a[-(12-hours)..-1]
    end

    yesterday_hours.each do |hour|
      daily_data.unshift GrouponDeal.by_hour(hour, true)
    end

    hours.times do |i|
      daily_data.unshift GrouponDeal.by_hour(i)
    end

    daily_data.each_with_index do |day, i|
      count = day.count
      next if count == 0 || i == 0
      average_price = day.map {|x| x.pricetext.to_f}.sum / count

      begin
        now_count = day.inject(0) {|sum, x| sum += x.count.to_f }
        earlier_count = daily_data[i-1].inject(0) {|sum, x| sum += x.count.to_f }
      rescue
        next
      end

      num_deals = now_count - earlier_count

      aggregates << [day.first.time, self.round(average_price * num_deals.abs)]
    end
    [aggregates.map(&:first), aggregates.map(&:last)]
  end

  # workaround rounding bug in MRI 1.8.7
  def self.round(num)
    ("%.2f" % num).to_f
  end
end
