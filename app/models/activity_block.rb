class ActivityBlock
  attr_reader :from, :to, :records
  delegate  :deal_count, :active_deals, :closed_deals, :average_coupon_price, 
            :average_deal_coupons, :average_deal_revenue,
            :total_coupons, :total_revenue, 
            :to => :my_scope  
  
  attr_reader :from, :to, :diffables, :calculations
  alias :time :from
  def initialize(diffables, opts = {})
    opts.reverse_merge! :from => 1.day.ago, :to => Time.now, :calculations => :total_revenue
    
    @from, @to = opts[:from].to_time, opts[:to].to_time
    @diffables, @calculations = Array.wrap(diffables), Array.wrap(opts[:calculations])
  end
  
  def ids
    @ids  ||= @diffables.map(&:id)
  end
  
  def calculation_scope
    SnapshotDiff.where(field.in => ids).where(:changed_at => from .. to).group(field)
  end
  
  def field
    @field ||= "#{diffables.first.class.to_s.underscore}_id".to_sym
  end
  
  # ensures we have a record for every time slot for every relation
  def default_values
    ids.map_to_hash{ |id| {id => 0} }
  end
  
  def run_calculation(calculation)
    calculation_scope.send(calculation).reverse_merge(default_values)
  end
  
  def resource_calculations
    @resource_calculations ||= begin
      resource_id_calculations = ids.map_to_hash{ |id| {id => {}}}
      
      calculations.each do |calculation|
        Rails.logger.info "[CHART]: calculating #{calculation.to_s} for #{to}, from #{calculation_scope.to_sql}"
        run_calculation(calculation).each do |resource_id, value|
          resource_id_calculations[resource_id][calculation] = value
        end
      end
      
      diffables.map do |resource|
        [resource, Hashie::Mash.new(resource_id_calculations[resource.id])]
      end
    end
  end
  
  def by_interval(interval)
    rounded_from, rounded_to = from.to_time.floor(interval), to.to_time.floor(interval)
    last_step = rounded_from
    
    # maximum # of queries should be <= # of intervals * # of calculations
    time_frames = (rounded_from + interval .. rounded_to).step(interval).map do |step|
      ActivityBlock.new(diffables, :from => last_step, :to => step, :calculations => calculations)
    end
  end
  
  def hours
    by_interval 1.hour
  end
end