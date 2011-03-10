class Snapshot
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url
  field :site_id,   :type => Integer
  field :deal_id
  field :status # active/pending/closed/nonexistent
  field :price
  field :buyers_count,    :type => Integer
  field :raw_data      # TODO: bzip
  field :deal_exists,   :type => Boolean, :default => false
  field :analyzed,      :type => Boolean, :default => false
  field :deal_attrs,    :type => Hash
  
  scope :existent,            where(:deal_exists => true)
  scope :nonexistent,         where(:deal_exists => false)
  
  scope :valid_for_analysis,  excludes(:price => nil, :buyers_count => nil)
  scope :needs_analysis,      excludes(:analyzed => true)
  scope :analyzed,            where(:analyzed => true)
  
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
  #scope :current, lambda { where(time_gt_than(2.hours.ago.utc)) }

  before_save :load_attrs_from_deal_importer, :on => :create

  attr_writer :deal_importer, :cache_available

  def self.from_importer(deal_importer)
    puts "creating snapshot for #{deal_importer.url}"

    create(:deal_importer => deal_importer)
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
  
  def deal_exists?
    status != :nonexistent
  end
  
  def previous_snapshot
    @previous_snapshot ||= self.class.older_than(created_at).where(:site_id => site_id, :deal_id => deal_id).last
  end

  def total_revenue
    price * buyers_count
  end
  
  def revenue_change
    buyer_change * price
  end
  
  def buyer_change
    @buyer_change  ||= buyers_count - previous_snapshot.buyers_count
  end
  
  def active?
    status == :active
  end
  
  def closed?
    status == :closed
  end
  
  def set_closed
    @closed  = closed? and previous_snapshot.active?
  end

  def changed_from_previous?
    previous_snapshot and (buyer_change > 0 || set_closed)
  end

  def cache_available
    @cache_available != false
  end

  def reload_url
    self.cache_available = false
    deal_importer.parse
    
    self.status         = deal_importer.status
    self.deal_exists    = deal_importer.deal_exists?
    self.raw_data       = deal_importer.raw_data
    self.save

    self.cache_available = true
  end
  
  # TODO: DRY all this attribute/parsing/caching nonsense
  def load_attrs_from_deal_importer
    # FIXME: need this to populate the instance variables
    deal_importer.parse
    
    self.attributes = {
      :url          => deal_importer.url, 
      :deal_id      => deal_importer.deal_id, 
      :site_id      => deal_importer.site.id, 
      :status       => deal_importer.status,
      :raw_data     => deal_importer.raw_data,
      :deal_exists  => deal_importer.deal_exists?,
    }
    
    # load up attrs for an existing deal
    if deal_exists?
      self.attributes = {
        :price        => deal_importer.price,
        :buyers_count => deal_importer.buyers_count,
      }
    end
  end
  
  def deal_attrs
    @deal_attrs ||= {
      :deal_id        => deal_id,
      :status         => status,
      :url            => url,
    }.merge(existent_deal_attrs)
  end
  
  def existent_deal_attrs
    @existent_deal_attrs ||= {
      :title          => deal_importer.title,
      :active         => active?,
      :price          => deal_importer.price,
      :value          => deal_importer.value,
      :currency       => deal_importer.currency,
      :buyers_count   => deal_importer.buyers_count,
      :latitude       => deal_importer.location.try(:first),
      :longitude      => deal_importer.location.try(:last),  
    }
  end

  def reload_attributes
    load_attrs_from_deal_importer
    
    self.save
  end

  def valid_for_analysis?
    deal_importer.parse
    
    if deal_importer.valid?
      true
    else
      update_attribute(:status, :invalid)
      false
    end
  end

  def self.generate_diffs
    valid_for_analysis.needs_analysis.each(&:generate_diff)
  end
  
  def deal
    return unless deal_exists?
    
    @deal ||= begin
      deal   = site.deals.find_by_deal_id(deal_id)
      deal ||= site.deals.create(deal_attrs)
    end
  end
  
  # TODO: refactor and move this to deal_importer
  def fetch_new_snapshot
    self.cache_available = false
    deal_importer.save_snapshot
    self.cache_available = true
  end
  
  def generate_diff
    if valid_for_analysis? and changed_from_previous?
      puts "generating diff"
      diff_attrs = {
        :buyer_change       => buyer_change,
        :revenue_change     => revenue_change,
        :closed             => set_closed,
        :changed_at         => created_at
      }
      
      deal.snapshot_diffs.create(diff_attrs.merge(:start_snapshot_id => previous_snapshot.id, :end_snapshot_id => id))
    else
      puts "no diff needed"
    end
    
    update_attribute(:analyzed, true)
  end
end