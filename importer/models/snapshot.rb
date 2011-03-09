class Snapshot
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url
  field :site_id,   :type => Integer
  field :deal_id
  field :raw_data      # TODO: bzip
  field :status # active/pending/closed/nonexistent
  field :analyzed,  :type => Boolean
  
  scope :needs_analysis, where(:analyzed => false)
  
  def self.time_gt_than(time)
    js_time = "new Date(#{time.year}, #{time.month - 1}, #{time.day}, #{time.hour}, #{time.min})"
    "function() {return this.created_at >= #{js_time}}"
  end
  
  def self.time_lt_than(time)
    js_time = "new Date(#{time.year}, #{time.month - 1}, #{time.day}, #{time.hour}, #{time.min})"
    "function() {return this.created_at <= #{js_time}}"
  end
  
  scope :current,         lambda { where(time_gt_than(1.hours.ago.utc)) }
  scope :older_than,      lambda { |time| where(time_lt_than(time)) }
  scope :needs_analysis,  where(:analyzed => false)
  #scope :current, lambda { where(time_gt_than(2.hours.ago.utc)) }
  
  def self.from_importer(deal)
    puts "creating snapshot for #{deal.url}"
    create(:url => deal.url, :deal_id => deal.deal_id, :site_id => deal.site.id, 
            :status => deal.status, :raw_data => deal.raw_data)
  end
  
  def site
    @site ||= Site.find(site_id)
  end
  
  def deal_importer
    @deal_importer ||= begin
      deal_importer = site.importer.new(deal_id)
      deal_importer.current_snapshot = self
      deal_importer
    end
  end
  
  def previous_snapshot
    @previous_snapshot ||= self.class.older_than(created_at).where(:site_id => site_id, :deal_id => deal_id).last
  end
  
  def self.analyze
    needs_analysis.each(&:generate_diff)
  end
  
  delegate :buyers_count, :price, :to => :deal_importer
  
  def total_revenue
    price * buyers_count
  end
  
  def deal_exists?
    status != :nonexistent
  end
  
  def buyer_change
    @buyer_change  ||= buyers_count - previous_snapshot.buyers_count
  end
  
  def closed
    @closed  = !active and previous_snapshot.active
  end
  
  def changed_from_previous?
    previous_snapshot and (buyer_change > 0 || closed)
  end
  
  attr_writer :cache_available
  def cache_available
    @cache_available != false
  end
  
  def reload_attributes
    self.cache_available = false
    self.status = deal_importer.status
    self.save
    self.cache_available = true
  end
  
  def generate_diff
    if changed_from_previous?
      SnapshotDiff.create(
        :deal_id            => deal_id,
        :start_snapshot     => previous_snapshot, 
        :end_snapshot       => self,
        :buyer_change       => buyer_change,
        :revenue_change     => buyer_change * deal.price,
        :closed             => closed,
        :changed_at         => created_at
      )
    end
    
    self.analyzed = true
    save
  end
end