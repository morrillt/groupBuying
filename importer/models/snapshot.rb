class Snapshot
  include GroupBuying::Mongoid::Doc
  
  field :url
  field :site_id,         :type => Integer
  field :division_id,     :type => Integer
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
  scope :older_than,      lambda { |time| where(mcc(:created_at, :lt, time))       }
  
  delegate :title, :buyers_count, :price, :original_price, :total_revenue, :currency, :division_id, :to => :snapshooter
    
  attr_writer :snapshooter
  
  def self.most_recent
    desc(:created_at).first
  end
  
  def active?
    status != :active
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
      puts "loading cached snapshooter for #{url} (#{id})"
      snapshooter = site.snapshooter(deal_id)
      snapshooter.current_snapshot = self
      snapshooter.parse! # TODO? should we auto-parse?
      snapshooter
    end
  end
  
  def other_valid_snapshots
    self.class.valid_deal.where(:mysql_deal_id => mysql_deal_id).excludes(:id => id.to_s)
  end
  
  def previous_snapshot
    @previous_snapshot ||= other_valid_snapshots.older_than(created_at).desc(:created_at).limit(1).first
  end
end