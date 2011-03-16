class Snapshot < ActiveRecord::Base
  belongs_to :site
  belongs_to :deal
  
  before_create :capture_current_revenue
  
  scope :recent, :conditions => ["created_at >= ?", 1.minute.ago.at_midnight.to_s(:db)], :include => [:site], :order => "created_at ASC"
  
  def price
    deal.try(:sale_price)
  end
  
  def buyers_count
    deal.try(:buyers_count)
  end
  
  def total_revenue
    (price.to_f * buyers_count.to_f)
  end
  
  private
  
  def capture_current_revenue
    self.sold_count = deal.capture_snapshot
  end
end
