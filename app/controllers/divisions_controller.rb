class DivisionsController < InheritedResources::Base
  belongs_to :site, :finder => :find_by_name
  include ChartableController
  
  def collection
    @divisions ||= parent.divisions.order(:last_checked_at.desc)
  end
end