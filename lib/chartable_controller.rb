module ChartableController
  extend ActiveSupport::Concern
  
  included do
    before_filter :load_chart, :only => [:show, :index]
  end
  
  def load_chart
    chartable = action_name == 'index' ? collection.limit(6) : [resource]
    @chart    = Chart.new(params.slice(:from, :to).merge(:relations => chartable))
  end
end