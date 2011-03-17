class Site < ActiveRecord::Base
  has_many :snapshots
  has_many :deals, :through => :divisions
  has_many :divisions

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
  
  def revenue_per_hour(time)
    snapshots.find(:all, :conditions => ["created_at between ? and ?", time, time+1.hour], :include => [:site], :order => "created_at ASC")
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
