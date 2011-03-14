class Comparison
  def initialize(a, b)
    @a, @b = a, b
  end
  
  def deltas
    deltas = [
      [:closed_deals,             "# of closed deals"],
      [:total_coupons,            "# of coupons purchased"],
      [:total_revenue,            "$ spent on deals"],
#      [:average_deal_revenue,     "Average Revenue per deal"],      
    ]
    
    deltas.map do |method, name|
      start  = @a.run_calculation(method)
      finish = @b.run_calculation(method)
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