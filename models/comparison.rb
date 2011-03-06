class Comparison
  def initialize(opts = {})
    opts.reverse_merge! :from => Date.yesterday, :to => Date.today, :site => Site.first
    
    @a_scope = opts[:site].snapshot_diffs.by_day opts[:from]
    @b_scope = opts[:site].snapshot_diffs.by_day opts[:to]
  end
  
  def deltas
    deltas = [
      [:deals_closed,         "# of closed deals"],
      [:coupons_purchased,    "# of coupons purchased"],
      [:total_spent,          "$ spent on deals"],
      [:average_revenue,      "Average Revenue per deal"],      
    ]
    
    deltas.map do |method, name|
      start  = @a_scope.send(method)
      finish = @b_scope.send(method)
      puts "#{method}: #{start.inspect} / #{finish.inspect}"
      
      OpenStruct.new(
        :name => name, 
        :start => start, 
        :finish => finish, 
        :change => finish.percent_change_from(start)
      )
    end
  end
end