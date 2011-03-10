class Snapshot
  include GroupBuying::Mongoid::Doc
  
  field :url
  field :site_id,         :type => Integer
  field :deal_id
  field :mysql_deal_id,   :type => Integer
  field :raw_data      # TODO: bzip
  field :status # active/pending/closed/invalid      !nonexistent
  field :analyzed,      :type => Boolean, :default => false
  field :valid_deal,    :type => Boolean
  
  index :created_at
  index :analyzed
  index :valid_deal
  
  validates_presence_of :url, :site_id, :deal_id, :raw_data, :status
  
  scope :valid_deal,          where(:valid_deal => true)
  scope :needs_analysis,      where(:analyzed => false, :valid_deal => true)
  scope :analyzed,            where(:analyzed => true)
  
  scope :current,         lambda { where( mcc(:created_at, :gte, 1.hour.ago) )      }
  scope :recent,          lambda { where( mcc(:created_at, :gte, 4.hours.ago.utc))  }
  scope :older_than,      lambda { |time| where(mcc(:created_at, :lte, time))       }
  
  delegate :title, :buyers_count, :price, :original_price, :total_revenue, :currency, :to => :snapshooter
    
  attr_writer :snapshooter, :cache_available
  
  def active?
    status != :active
  end
  
  def cache_available
    @cache_available != false
  end
  
  def site
    @site ||= Site.find(site_id)
  end
  
  def deal
    @deal ||= Deal.find_by_id(mysql_deal_id)
  end
  
  def reload_from_raw
    update_attributes(:valid_deal => snapshooter.valid?, :status => snapshooter.status)
    deal.try(:update_cached_stats)
  end
  
  def snapshooter
    @snapshooter ||= begin
      puts "loading cached snapshooter for #{url}"
      snapshooter = site.snapshooter(deal_id)
      snapshooter.current_snapshot = self
      snapshooter.parse! # TODO? should we auto-parse?
      snapshooter
    end
  end
  
  def previous_snapshot
    @previous_snapshot ||= self.class.valid_deal.older_than(created_at).where(:url => url).desc(:created_at).limit(1).first
  end
end