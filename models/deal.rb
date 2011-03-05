class Deal < ActiveRecord::Base
  belongs_to  :site
  has_many    :snapshots
  
  scope :active,      where(:active => true)
  scope :closed,      where(:active => false)
  
  scope :zip_codes,   select("DISTINCT(zip_code)")
  
  scope :by_day,      lambda { |day| where(:data_date => day.to_date) }
  scope :yesterday,   by_day(1.day.ago)
  scope :today,       by_day(Date.today)
  
  def hotness_index
    initial_buyer_count = snapshots.first.buyers
    end_buyer_count  = snapshots.last.buyers
    
    end_buyer_count.percent_change_from(initial_buyer_count)
  end
  
  def spent
    price * buyers_count
  end
  
  def buyers_count
    @buyers_count ||= read_attribute(:buyers_count) || begin
      current_count = snapshots.current.first.try(:buyers)
      update_attribute(:buyers_count, current_count) if current_count
      
      current_count
    end
  end
  
  class << self
    def buying_dynamics
      [
        ["# of active deals being tracked",   active.count],
        ["# of deals tracked to date",        all.count],
        ["# of coupons purachased to date",   total_buyers],
        ["Total spent on deals to date:",     total_spent],
        ["Average revenue per deal",          average_revenue],
        ["# of Zip codes we're following",    zip_codes.count],
      ]
    end

    def total_buyers
      all.sum(&:buyers_count)
    end

    def total_spent
      all.sum(&:spent)
    end

    def average_revenue
      total_spent / count
    end

    def closed_count
      closed.count
    end

    def chart_data
      chart = (10.days.ago.to_date .. Date.today).map_to_hash do |day| 
        next unless (deals = Deal.by_day(day)).present?
        
        { day => deals.avg_rev }
      end
    end

    def hot_deals
      unique.limit(30).sort_by{ |deal| -deal.hotness_index }.take(10)
    end
  end
end