class Snapshot < ActiveRecord::Base
  belongs_to :site
  belongs_to :deal
  
  before_create :capture_current_revenue
  
  scope :recent, :conditions => ["created_at >= ?", 1.minute.ago.at_midnight.to_s(:db)], :include => [:site], :order => "created_at ASC"
  
  private
  
  def capture_current_revenue
    self.sold_count = deal.capture_snapshot
  end
end
