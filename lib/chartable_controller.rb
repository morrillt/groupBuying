module ChartableController
  extend ActiveSupport::Concern
  
  included do
    before_filter :load_chart, :only => [:show, :index]
  end
  
  def load_chart
    chartables = action_name == 'index' ? collection.first(6) : [resource]
    
    @chart    = Chart.new(chartables, params.slice(:from, :to))
  end
end