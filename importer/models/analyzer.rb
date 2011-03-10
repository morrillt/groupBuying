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
    @buyer_change ||= snap.buyers_count - old_snap.buyers_count
  end
  
  def revenue_change
    @revenue_change ||= buyer_change * snap.price
  end
  
  def valid_old_snap?
    old_snap.try(:valid?)
  end
  
  def changed_from_previous?
    return unless valid_old_snap?
    
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