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
  
  # Returns a new instance of the Site Snapshooter class
  # Example:
  #  Snapshooter::KgbDeals.new
  def snapshooter
    case self.source_name
    when 'kgb_deals'
      Snapshooter::KgbDeals.new
    when 'travel_zoo'
      Snapshooter::TravelZoo.new
    when 'homerun'
      Snapshooter::Homerun.new
    else
      raise Exception, "Unknown site source_name #{self.source_name}"
    end
  end
end
