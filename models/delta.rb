class Delta
  def self.generate(start_scope, finish_scope)
    deltas = [
      [:closed_count,     "# of closed deals"],
      [:num_coupons,      "# of coupons purchased"],
      [:spent,            "$ spent on deals"],
      [:average_revenue,  "Average Revenue per deal"],      
    ]
    
    deltas.map do |method, name|
      start  = start_scope.send(method)
      finish = finish_scope.send(method)
      puts "#{method}: #{start.inspect} / #{finish.inspect}"
      OpenStruct.new(:name => name, :start => start, :finish => finish, :change => finish.percent_change_from(start))
    end
  end
end