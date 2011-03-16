class Snapshot < ActiveRecord::Base
  belongs_to :deal
  
  before_create :capture_current_revenue
  
  private
  
  def capture_current_revenue
    self.sold_count = deal.capture_snapshot
  end
end
