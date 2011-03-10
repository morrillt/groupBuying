class Analyzer
  def self.analyze_snapshots
    Snapshot.needs_analysis.asc(:created_at).limit(100).each do |snap|
      analyzer = new(snap)
      analyzer.process
    end
  end
  
  attr_reader :snap, :old_snap, :snapshooter, :site, :deal
  def initialize(snap)
    @snap         = snap
    @snapshooter  = snap.snapshooter
    @old_snap     = snap.previous_snapshot
    @site         = snap.site
    @deal         = nil
  end
  
  def process
    if snapshooter.valid?
      find_or_create_deal
      generate_diff
    else
      puts "invalid snap from: #{snap.url}"
    end
    
    snap.update_attributes(:mysql_deal_id => deal.try(:id), :analyzed => true)
  end
  
  def find_or_create_deal
    @deal ||= begin
      puts "creating deal from: #{snap.url}"
      deal   = site.deals.find_by_deal_id(snap.deal_id)
      deal ||= site.deals.create(snapshooter.deal_attrs)
    end
  end
  
  def buyer_change
    @buyer_change ||= valid_old_snap? ?
      snap.buyers_count - old_snap.buyers_count :
      snap.buyers_count
  end
  
  def revenue_change
    @revenue_change ||= buyer_change * snap.price
  end
  
  def valid_old_snap?
    old_snap.try(:valid?)
  end
  
  def changed_from_previous?
    buyer_change > 0 || set_closed
  end
  
  def set_closed
    @closed ||= !!(! snap.active? and old_snap.try(:active?))
  end
  
  def generate_diff
    if changed_from_previous?
      puts "generating diff from #{snap.url}"
      diff_attrs = {
        :buyer_change       => buyer_change,
        :revenue_change     => revenue_change,
        :closed             => set_closed,
        :changed_at         => snap.created_at
      }
      
      deal.snapshot_diffs.create(diff_attrs.merge(:old_snapshot_id => old_snap.try(:id), :snapshot_id => snap.id))
    else
      puts "no diff needed from #{snap.url}"
    end
  end
end

# def total_revenue
#   return unless valid_for_analysis?
#   
#   price * buyers_count
# end
# 
# def revenue_change
#   return unless valid_for_analysis?
#   
#   buyer_change * price
# end
# 
# def buyer_change
#   return unless buyers_count and previous_snapshot.buyers_count
#   
#   @buyer_change  ||= buyers_count - previous_snapshot.buyers_count
# end
# 
# def active?
#   status == :active
# end
# 
# def closed?
#   status == :closed
# end
# 

# 
# 
# def reload_url
#   self.cache_available = false
#   deal_importer.parse
#   
#   self.status         = deal_importer.status
#   self.deal_exists    = deal_importer.deal_exists?
#   self.raw_data       = deal_importer.raw_data
#   self.save
# 
#   self.cache_available = true
# end
# 
# # TODO: DRY all this attribute/parsing/caching nonsense
# def load_attrs_from_deal_importer
#   # FIXME: need this to populate the instance variables
#   deal_importer.parse
#   
#   self.attributes = {
#     :url          => deal_importer.url, 
#     :deal_id      => deal_importer.deal_id, 
#     :site_id      => deal_importer.site.id, 
#     :status       => deal_importer.status,
#     :raw_data     => deal_importer.raw_data,
#     :deal_exists  => deal_importer.deal_exists?,
#   }
#   
#   # load up attrs for an existing deal
#   if deal_exists?
#     self.attributes = {
#       :price        => deal_importer.price,
#       :buyers_count => deal_importer.buyers_count,
#     }
#   end
# end
# 
# def deal_attrs
#   @deal_attrs ||= {
#     :deal_id        => deal_id,
#     :status         => status,
#     :url            => url,
#   }.merge(existent_deal_attrs)
# end
# 
# def existent_deal_attrs
#   @existent_deal_attrs ||= {
#     :title          => deal_importer.title,
#     :active         => active?,
#     :price          => deal_importer.price,
#     :value          => deal_importer.value,
#     :currency       => deal_importer.currency,
#     :buyers_count   => deal_importer.buyers_count,
#     :latitude       => deal_importer.location.try(:first),
#     :longitude      => deal_importer.location.try(:last),  
#   }
# end
# 
# def reload_attributes
#   load_attrs_from_deal_importer
#   
#   self.save
# end
# 

# 

# 

# 
# # TODO: refactor and move this to deal_importer
# def fetch_new_snapshot
#   self.cache_available = false
#   deal_importer.save_snapshot
#   self.cache_available = true
# end
# 
