class Snapshot
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url
  field :exists,    :type => Boolean
  field :site_id,   :type => Integer
  field :raw_data      # TODO: bzip
  
  field :state # active/closed/nonexistent
  
  after_create :generate_diff
  
  def self.time_gt_than(time)
    js_time = "new Date(#{time.year}, #{time.month - 1}, #{time.day}, #{time.hour}, #{time.min})"
    "function() {return this.created_at >= #{js_time}}"
  end
  
  scope :current, lambda { where(time_gt_than(1.hours.ago.utc)) }
  #scope :current, lambda { where(time_gt_than(2.hours.ago.utc)) }
  
  def self.from_importer(deal)
    puts "creating snapshot for #{deal.url}"
    create(:url => deal.url, :site_id => deal.site.id, :state => deal.exists?, :raw_data => deal.doc.to_s)
  end
  
  def still_active?
    active and imported_at > 1.hour.ago
  end
  
  def total_revenue
    deal.price * buyers_count
  end
  
  def previous_snapshot
    @previous_snapshot ||= deal.snapshots.where(:imported_at.lt => imported_at).last
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