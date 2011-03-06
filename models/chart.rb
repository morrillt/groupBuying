class Chart
  attr_reader :from, :to, :interval, :labels
  
  def initialize(opts = {})
    opts.reverse_merge! :from => 16.hours.ago, :to => Time.now, :interval => 1.hour
    @interval = opts[:interval]
    @from, @to = opts[:from].to_time.floor(interval), opts[:to].to_time.floor(interval)
    @sites = Site.all
    
    generate_chart_data
  end
  
  def datasets
    @datasets#.map{ |site_name, values| {'name' => site_name, 'data' => values}}
  end
  
  def generate_chart_data
    @labels, @datasets = [], {}
    last_step = from
    
    chart = (from + interval .. to).step(interval).each do |step|
      @labels << step.strftime('%H:%M')
      
      @sites.each do |site|
        @datasets[site.name] ||= []
        @datasets[site.name] << site.snapshot_diffs.where(:changed_at => last_step .. step).total_spent
      end
      
      last_step = step
    end
  end
  
end