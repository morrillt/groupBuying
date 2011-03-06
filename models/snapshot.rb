class Snapshot < ActiveRecord::Base
  belongs_to :deal
    
  after_create :generate_diff
  
  def total_revenue
    deal.price * buyers_count
  end
  
  def previous_snapshot
    @previous_snapshot ||= deal.snapshots.where(:id.lt => id).last
  end
  
  def buyer_change
    @buyer_change  ||= buyers_count - previous_snapshot.buyers_count
  end
  
  def closed
    @closed  = !active and previous_snapshot.active
  end
  
  def generate_diff
    return unless previous_snapshot
    return if buyer_change.zero? and not closed
    
    SnapshotDiff.create(
      :deal_id            => deal_id,
      :start_snapshot     => previous_snapshot, 
      :end_snapshot       => self,
      :buyer_change       => buyer_change,
      :revenue_change     => buyer_change * deal.price,
      :closed             => closed,
      :changed_at         => imported_at
    )
  end
end