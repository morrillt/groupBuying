class Analyzer
  def self.analyze_snapshots(num = 10)
    Snapshot.needs_analysis.asc(:created_at).limit(num).each do |snap|
      puts "analyzing #{snap.id}"
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
      deal   = site.deals.find_by_deal_id(snap.deal_id)
      
      unless deal.present?
        puts "creating deal from: #{snap.url}"
        deal = site.deals.create!(snapshooter.deal_attrs.merge(:division_id => snap.division_id))
      end
      
      deal
    end
  end
  
  def buyer_change
    @buyer_change ||= snap.buyers_count - old_snap.buyers_count
  end
  
  def revenue_change
    @revenue_change ||= buyer_change * snap.price
  end
  
  def valid_old_snap?
    !!old_snap.try(:valid?)
  end
  
  def changed_from_previous?
    return unless valid_old_snap?
    
    buyer_change > 0 || set_closed
  end
  
  def set_closed
    @closed ||= !!(! snap.active? and old_snap.active?)
  end
  
  def generate_diff
    if valid_old_snap? && changed_from_previous?
      puts "generating diff from #{snap.url}"
      diff_attrs = {
        :buyer_change       => buyer_change,
        :revenue_change     => revenue_change,
        :closed             => set_closed,
        :changed_at         => snap.created_at,
        :old_snapshot_id    => old_snap.id.to_s,
        :snapshot_id        => snap.id.to_s,
        :site_id            => snap.site_id,
        :division_id        => snap.division_id,
      }
      diff = deal.snapshot_diffs.where(diff_attrs.slice(:snapshot_id, :old_snapshot_id)).first || deal.snapshot_diffs.build
      diff.update_attributes!(diff_attrs)
    else
      puts "no diff needed from #{snap.url} | #{valid_old_snap?.to_s} / #{changed_from_previous?.to_s} "
    end
  end
end