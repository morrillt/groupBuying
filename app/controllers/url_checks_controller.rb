class UrlChecksController < InheritedResources::Base
  belongs_to :site, :finder => :find_by_name
  
  def collection
    @url_checks ||= parent.url_checks.desc(:created_at).paginate(:page => params[:page])
  end
end