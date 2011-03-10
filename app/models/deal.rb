class Deal < ActiveRecord::Base
  belongs_to  :site
  belongs_to  :division
  #has_many    :snapshots, :order => :imported_at
  has_many    :snapshot_diffs
  
  scope :active,        where(:active => true)
  scope :closed,        where(:active => false)
  scope :hot,           order(:hotness.desc)
  
  scope :unique_divisions, select("DISTINCT(division_id)")
  
  scope :for_calc,      where(:buyers_count.ne => nil)
  scope :needs_update,  active.where(:updated_at.lt => 30.minutes.ago)
  scope :never_cached,  where(:buyers_count => nil)
  
  def self.update_cached_stats
    (never_cached + needs_update).each(&:update_cached_stats)
  end
  
  def location
    [latitude, longitude]
  end
  
  def location=(lat_lng)
    if lat_lng.is_a?(Array)
      self.latitude   = lat_lng.first
      self.longitude  = lat_lng.last
    end
  end
  
  def update_cached_stats(snap = nil)
    snap ||= snapshots.current.first
    
    update_attributes(:buyers_count => snap.buyers_count,
      :hotness => calculate_hotness,
      :active  => snap.status == :active) if snap
  end
  
  def import
    if snap = create_snapshot
      update_cached_stats
    else
      touch
    end
  end
  
  def create_snapshot
    snapshooter.create_snapshot
  end
  
  def snapshooter
    @deal_importer ||= site.snapshooter(deal_id)
  end
  
  def snapshots
    site.snapshots.where(:deal_id => deal_id)
  end
  
  def calculate_hotness
    initial_buyer_count = snapshots.first.buyers_count
    end_buyer_count     = snapshots.last.buyers_count
    
    end_buyer_count.to_i.percent_change_from(initial_buyer_count) if initial_buyer_count and end_buyer_count
  end
  
  def revenue
    price * buyers_count
  end
  
  class << self
    def buying_dynamics
      [
        ["# of active deals being tracked",   active.count],
        ["# of deals tracked to date",        all.count],
        ["# of coupons purachased to date",   total_buyers],
        ["Total spent on deals to date:",     total_revenue],
        ["Average revenue per deal",          average_revenue],
        ["# of 'divisions' we're following",  unique_divisions.count],
      ]
    end

    def total_buyers
      for_calc.sum(:buyers_count)
    end

    def total_revenue
      for_calc.to_a.sum(&:revenue)
    end

    def average_revenue
      return 0 if count.zero?
      
      total_revenue / count
    end
  end
end