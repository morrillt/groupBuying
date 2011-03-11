class DealsController < InheritedResources::Base
  belongs_to :site, :optional => true, :finder => :find_by_name
  include ChartableController
  
  def import
    resource.import
    
    redirect_to resource, :notice => "Took new snapshot"
  end
  
  def collection
    @deals ||= end_of_association_chain.paginate(:page => params[:page])
  end
end