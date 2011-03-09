class Deal < ActiveRecord::Base
  belongs_to  :site
  belongs_to  :division
  has_many    :snapshots, :order => :imported_at
  has_many    :snapshot_diffs
  
  scope :active,        where(:active => true)
  scope :closed,        where(:active => false)
  scope :hot,           order(:hotness.desc)
  
  #scope :zip_codes,     select("DISTINCT(zip_code)")
  
  scope :for_calc,      where(:buyers_count.ne => nil)
  scope :needs_update,  active.where(:updated_at.gt => 30.minutes.ago)
  scope :never_cached,  where(:buyers_count => nil)
  
  def self.update_cached_stats
    (never_cached + needs_update).each(&:update_cached_stats)
  end
  
  def update_cached_stats
    update_attributes(:buyers_count => snapshots.last.try(:buyers_count), 
      :hotness => calculate_hotness,
      :active  => is_active?)
  end
  
  def is_active?
    snapshots.last.try(:still_active?)
  end
  
  def calculate_hotness
    initial_buyer_count = snapshots.first.buyers_count
    end_buyer_count     = snapshots.last.buyers_count
    
    end_buyer_count.percent_change_from(initial_buyer_count)
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
        ["# of Zip codes we're following",    zip_codes.count],
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