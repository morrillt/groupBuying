class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def render_404
    render :text => File.read(RAILS_ROOT + '/public/404.html'), :status => 404
  end
end
