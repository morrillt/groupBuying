class Chart
  attr_reader :from, :to, :interval, :labels, :datasets
  
  def initialize(opts = {})
    opts.reverse_merge! :from => 16.hours.ago, :to => Time.now, :interval => 1.hour
    @from, @to, @interval = opts[:from], opts[:to], opts[:interval]
    @sites = Site.all
    
    generate_chart_data
  end
  
  def generate_chart_data
    @labels, @datasets = [], {}
    
    @sites.each do |site|
      site.activity_block(:from => @from, :to => @to).by_interval(@interval).each do |ab|
        this_label = ab.name.strftime("%H:00")
        @labels << this_label unless @labels.last == this_label || ab.name.hour.odd?
        
        @datasets[site.title] ||= []
        @datasets[site.title] << ab.total_revenue
      end
    end
  end
  
end