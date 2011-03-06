class SnapshotDiff < ActiveRecord::Base
  belongs_to :deal
  belongs_to :start_snapshot, :class_name => 'Snapshot'
  belongs_to :end_snapshot,   :class_name => 'Snapshot'
  
  scope :by_day,  lambda{ |day| where(:changed_at => day.to_date .. day.to_date + 1) }
  scope :closed,  where(:closed => true)
  
  class << self
    def average_revenue
      deals_closed.zero? ? 0 : (total_spent / deals_closed)
    end
    
    def deals_closed
      closed.count
    end
    
    def coupons_purchased
      sum(:buyer_change)
    end
    
    def total_spent
      sum(:revenue_change)
    end
  end
end