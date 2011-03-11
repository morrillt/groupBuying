class Deal < ActiveRecord::Base
  belongs_to  :site
  belongs_to  :division
  
  has_many    :snapshot_diffs
  
  scope :active,        where(:active => true)
  scope :closed,        where(:active => false)
  scope :hot,           order(:hotness.desc)
  
  scope :unique_divisions, select("DISTINCT(division_id)")
  
  scope :for_calc,      where(:buyers_count.ne => nil)
  scope :needs_update,  active.where(:updated_at.lt => 30.minutes.ago)
  scope :never_cached,  where(:buyers_count => nil)
  
  before_save do
    self.active = (status == :active)
    true # return true or the callback will abort the save
  end
  
  def self.update_cached_stats
    (never_cached + needs_update).each(&:update_cached_stats)
  end
  
  def name
    title.truncate(40).strip.gsub("\n", '').gsub(/\s+/, ' ')
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
    return unless current_snapshot
    
    new_attrs = {
      :buyers_count         => current_snapshot.buyers_count,
      :hotness              => calculate_hotness,
      :active               => current_snapshot.status == :active,
      :status               => current_snapshot.status,
      :current_snapshot_id  => current_snapshot.id.to_s,
      :price                => current_snapshot.price,
      :original_price       => current_snapshot.original_price,
    }
    update_attributes(new_attrs)
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
    site.snapshots.where(:mysql_deal_id => id)
  end
  
  def current_snapshot
    return unless current_snapshot_id
    
    @current_snapshot ||= site.snapshots.find(current_snapshot_id)
  end
  
  def first_snapshot
    @first_snapshot ||= snapshots.first
  end
  
  def calculate_hotness
    if first_snapshot != current_snapshot
      initial_buyer_count = first_snapshot.buyers_count
      end_buyer_count     = current_snapshot.buyers_count
      end_buyer_count.to_i.percent_change_from(initial_buyer_count) if initial_buyer_count and end_buyer_count
    end
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