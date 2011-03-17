class Snapshot < ActiveRecord::Base
<<<<<<< HEAD
  belongs_to :site
=======
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
  belongs_to :deal
  
  before_create :capture_current_revenue
  
<<<<<<< HEAD
  scope :recent, :conditions => ["created_at between ? and ?", 1.day.ago.at_midnight, Time.now.at_midnight], :include => [:site], :order => "created_at ASC"
  
  def price
    deal.try(:sale_price)
  end
  
  def buyers_count
    deal.try(:buyers_count)
  end
  
  def total_revenue
    (price.to_f * buyers_count.to_f)
  end
  
=======
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
  private
  
  def capture_current_revenue
    self.sold_count = deal.capture_snapshot
<<<<<<< HEAD
    self.sold_since_last_snapshot_count = (self.sold_count - deal.snapshots.last.sold_count)
=======
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
  end
end
