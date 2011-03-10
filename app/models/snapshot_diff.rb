class SnapshotDiff < ActiveRecord::Base
  belongs_to :deal
  belongs_to :old_snapshot,   :class_name => 'Snapshot'
  
  scope :by_day,  lambda{ |day| where(:changed_at => day.to_date .. day.to_date + 1) }
  scope :closed,  where(:closed => true)
  
  validates_presence_of     :snapshot_id, :old_snapshot_id
  validates_uniqueness_of   :snapshot_id, :scope => :old_snapshot_id
  
  def snapshot
    Snapshot.find(snapshot_id)
  end
  
  def old_snapshot
    Snapshot.find(old_snapshot_id)
  end
  
  class << self
    # the average revenue per deal
    def deal_count
      count('distinct(snapshot_diffs.deal_id)')
    end
    
    def active_deals
      deal_count - closed_deals
    end
    
    def closed_deals
      closed.count('distinct(snapshot_diffs.deal_id)')
    end
    
    def average_deal_coupons
      deal_count.zero? ? 0 : total_coupons / deal_count
    end
    
    def average_deal_revenue
      deal_count.zero? ? 0 : total_revenue / deal_count
    end
    
    def average_coupon_price
      total_coupons.zero? ? 0 : total_revenue / total_coupons
    end
    
    def total_coupons
      sum(:buyer_change)
    end
    
    def total_revenue
      sum(:revenue_change)
    end
  end
end