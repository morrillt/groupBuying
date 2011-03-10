class DealsController < InheritedResources::Base
  def import
    resource.import
    
    redirect_to resource, :notice => "Took new snapshot"
  end
end