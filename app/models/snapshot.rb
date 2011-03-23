class Snapshot < ActiveRecord::Base
  belongs_to :site
  belongs_to :deal
  
  before_create :capture_current_revenue
  
  
  scope :recent, :conditions => ["created_at between ? and ?", 1.day.ago.at_midnight, Time.now], :include => [:site], :order => "created_at ASC"
  
  def site_name
    @site_name ||= self.site.name
  end
  
  def deal_name
    @deal_name ||= self.deal.name
  end
  
  def price
    @price ||= deal.try(:sale_price)
  end
  
  def buyers_count
    sold_count
  end
  
  def total_revenue
    (price.to_f * buyers_count.to_f)
  end
  
  # Calls calculate_hotness! on deal to update hotness
  def calculate_hotness
    self.deal.has_more_than_one_snapshot? ? deal.calculate_hotness! : true
  end
  
  private
  
  def capture_current_revenue
    return true if Rails.env.test # rspec triggers it. But needed for development environment
    puts "Capturing snapshot for #{deal.inspect}"
    calculate_hotness
    self.sold_count = deal.capture_snapshot
    self.sold_since_last_snapshot_count = (self.sold_count - deal.snapshots.last.try(:sold_count).to_i)
  end
end
