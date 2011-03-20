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
    snapshooter.crawl_new_deals!
  end
  
  # Returns a new instance of the Site Snapshooter class
  # Example:
  #  Snapshooter::KgbDeals.new
  def snapshooter
    @snapshooter ||= case self.source_name
    when 'kgb_deals'
      Snapshooter::KgbDeals.new
    when 'travel_zoo'
      Snapshooter::TravelZoo.new
    when 'homerun'
      Snapshooter::Homerun.new
    when 'open_table'
      Snapshooter::OpenTable.new
    when 'groupon'
      Snapshooter::GrouponClass.new
    else
      raise Exception, "Unknown site source_name #{self.source_name}"
    end
  end

  # Returns the total revenue for all active deals of this site
  # for a given hour of a given date. 
  def revenue_by_given_hour_and_date(hour, date)
    snapshots= Snapshot.find_by_sql ["SELECT snapshots.deal_id, SUM(sold_since_last_snapshot_count) AS total_count, deals.sale_price FROM snapshots, deals WHERE snapshots.site_id = ? AND YEAR(snapshots.created_at) = ? AND MONTH(snapshots.created_at) = ? AND DAY(snapshots.created_at) = ? AND HOUR(snapshots.created_at) = ? AND sold_since_last_snapshot_count NOT IN (0) AND snapshots.deal_id = deals.id GROUP BY deal_id", self.id, date.year, date.month, date.day, hour]
    
    revenue= 0
    snapshots.each do |s|
      revenue += s.total_count * s.sale_price
    end
    revenue.to_f
  end

  # Returns the total revenue for each division of this site
  # within the given hour of the given date
  def revenue_for_all_divisions_by_given_hour_and_date(hour, date)
    snapshots= Snapshot.find_by_sql ["SELECT deals.division_id AS division_id, divisions.name, SUM(total_count*price) AS rev FROM (SELECT snapshots.site_id, snapshots.deal_id, MAX(sold_since_last_snapshot_count) AS total_count, deals.sale_price AS price FROM snapshots, deals WHERE snapshots.site_id = ?	AND YEAR(snapshots.created_at) = ? AND MONTH(snapshots.created_at) = ? AND DAY(snapshots.created_at) = ? AND HOUR(snapshots.created_at) = ? AND sold_since_last_snapshot_count NOT IN (0) AND snapshots.deal_id = deals.id GROUP BY deal_id) revenue, deals, divisions WHERE revenue.deal_id = deals.id AND deals.division_id = divisions.id GROUP BY division_id", self.id, date.year, date.month, date.day, hour]
  end

  def currently_trending
    Site.find_by_sql(["SELECT deals.name, deals.permalink, divisions.name as division, deals.hotness FROM deals, divisions WHERE deals.division_id = divisions.id AND deals.site_id = ? ORDER BY hotness DESC LIMIT 10", self.id])
  end

  def self.coupons_purchased_to_date
    find_by_sql("select SUM(c) as purchased from (SELECT deal_id, MAX(sold_count) AS c FROM snapshots GROUP BY deal_id order by deal_id desc) x").first.purchased.to_i
  end
end
