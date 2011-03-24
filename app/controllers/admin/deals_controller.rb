class Admin::DealsController < Admin::ApplicationController
  layout "admin"
  
  def index
    @model_name= 'deal'
  end
  
  def show
    @deal = Deal.find(params[:id], :include => [:site, :division])
  end
  
  def export
    csv_file_path = File.join(Rails.root, '..', 'shared', 'deals.csv')
    render_404 && return unless File.exists?(csv_file_path)
    send_file(csv_file_path, :content_type => "text/csv", :disposistion => "inline", :filename => "deals.csv")
  end
end
