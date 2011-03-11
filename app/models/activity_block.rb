class ActivityBlock
  attr_reader :from, :to, :records
  delegate  :deal_count, :active_deals, :closed_deals, :average_coupon_price, 
            :average_deal_coupons, :average_deal_revenue,
            :total_coupons, :total_revenue, 
            :to => :records  
  
  def initialize(opts = {})
    opts.reverse_merge! :from => 1.day.ago, :to => Time.now
    @from, @to = opts[:from].to_time, opts[:to].to_time
    @diffs = opts[:diffs] || opts[:association_chain].try(:snapshot_diffs) || SnapshotDiff
    
    @records = @diffs.where(:changed_at => from .. to)
  end
  
  def name
    from
  end
  
  def hours
    by_interval 1.hour
  end
  
  def by_interval(interval)
    rounded_from, rounded_to = from.to_time.floor(interval), to.to_time.floor(interval)
    last_step = rounded_from
    
    intervals = {}
    (rounded_from + interval .. rounded_to).step(interval).map do |step|
      ab = ActivityBlock.new(:from => last_step, :to => step, :diffs => @diffs)
      last_step = step
      
      ab
    end
  end
end