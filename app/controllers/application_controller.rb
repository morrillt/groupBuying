class ApplicationController < ActionController::Base
  protect_from_forgery

  # before_filter :authenticate_user!
  before_filter :http_authenticate
  before_filter :overall_trending
  
  def render_404
    render :text => File.read(Rails.root.to_s + '/public/404.html'), :status => 404
  end

  private
  def overall_trending
    @overall_trending= Deal.overall_trending
  end    
  
  def http_authenticate
    authenticate_or_request_with_http_basic do |username, password|
        username == "admin" && password == "GBin2011"
    end
  end
end