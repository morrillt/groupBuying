class GrouponDeal < ActiveRecord::Base
  set_table_name "groupon"

  attr_reader :deals

  scope :active, lambda { unique.where(:status   => true ) }
  scope :closed, lambda { unique.where(:status   => false) }
  scope :yesterday,  lambda { unique.where(:datadate => Date.today - 1.days) }
  scope :today,  lambda { unique.where(:datadate => Date.today) }
  scope :zip_codes, select("DISTINCT(location)")
  scope :unique, select("DISTINCT(deal_id), groupon.count, pricetext, datadate, location, status").order(:time).group(:deal_id)
  scope :by_deal, lambda { |id| select("datadate, time, count, location, deal_id").where(:deal_id => id).order("datadate DESC, time DESC") }
  scope :by_day, lambda { |day| where(:datadate => day) }
  
  class << self
    def num_coupons
      unique.all.sum(&:count)
    end

    def spent
      unique.all.sum(&:spent)
    end
    
    def average_revenue
      spent / count
    end
    
    def closed_count
      closed.length
    end
    
    def chart_data
      chart = (10.days.ago.to_date .. Date.today).map_to_hash do |day| 
        next unless (deals = GrouponDeal.by_day(day)).present?
        
        { day => deals.avg_rev }
      end
    end
    
    def hot_deals
      unique.limit(30).sort_by{ |deal| -deal.hotness_index }.take(10)
    end
  end
  
  def hotness_index
    @deals ||= GrouponDeal.by_deal(deal_id)
    
    finish_count = @deals.first.count
    start_count  = @deals.last.count
    
    finish_count.percent_change_from(start_count)
  end

  def count
    read_attribute(:count).to_i
  end
  
  def price
    pricetext.to_i
  end
  
  def spent
    price * count
  end
end
