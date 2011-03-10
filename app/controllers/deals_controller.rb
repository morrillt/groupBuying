class DealsController < InheritedResources::Base
  def import
    @deal.import
    
    redirect_to @deal
  end
end