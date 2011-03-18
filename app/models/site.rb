class Site < ActiveRecord::Base
  has_many :snapshots, :dependent => :destroy
  has_many :deals, :through => :divisions
  has_many :divisions, :dependent => :destroy

  scope :active, where(:active => true)
  
  # Updates all the sites active deals buy createing
  # snapshots of the deal
  def update_snapshots!
    deals.active.each do |deal|
      deal.take_snapshot!
    end
  end
  
  # Captures new deals in the database
  def crawl_new_deals
    snapshooter.crawl_new_deals
  end
  
  # Returns the total revenue for all active deals of this site
  # in a given hour of a given date. 
  # e.g. During the 17th hour of January 1st, 2666
  # There might be a better way to do this
  def revenue_by_given_hour_and_date(hour, date)
    snapshots= Snapshot.find_by_sql ["SELECT snapshots.deal_id, SUM(sold_since_last_snapshot_count) AS total_count, deals.sale_price FROM snapshots, deals WHERE snapshots.site_id = ? AND YEAR(snapshots.created_at) = ? AND MONTH(snapshots.created_at) = ? AND DAY(snapshots.created_at) = ? AND HOUR(snapshots.created_at) = ? AND sold_since_last_snapshot_count NOT IN (0) AND snapshots.deal_id = deals.id GROUP BY deal_id", self.id, date.year, date.month, date.day, hour]

    revenue= 0
    snapshots.each do |s|
      revenue += s.total_count * s.sale_price
    end
    revenue.to_f
  end

  # Returns a new instance of the Site Snapshooter class
  # Example:
  #  Snapshooter::KgbDeals.new
  def snapshooter
    case self.source_name
    when 'kgb_deals'
      Snapshooter::KgbDeals.new
    end
  end
end
