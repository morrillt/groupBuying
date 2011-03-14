class Chart
  attr_reader :from, :to, :chartables, :interval, :labels, :datasets
  
  def initialize(chartables, opts = {})
    opts.reverse_merge! :from => 16.hours.ago, :to => Time.now, :interval => 1.hour
    @from, @to, @interval = opts[:from], opts[:to], opts[:interval]
    @chartables = chartables
    
    generate_chart_data
  end
  
  def generate_chart_data
    @labels, @datasets = [], {}
    
    activity_block = ActivityBlock.new(chartables, :from => from, :to => to)
    activity_block.by_interval(interval).each do |time_frame|
      this_label = time_frame.time.strftime("%H:00")
      @labels << this_label unless @labels.last == this_label || time_frame.time.hour.odd?
      
      time_frame.resource_calculations.each do |resource, calculations|
        puts "got #{resource} | #{calculations.inspect}"
        @datasets[resource.chart_name]  ||= []
        @datasets[resource.chart_name]  << calculations.total_revenue
      end
    end
  end
  
end