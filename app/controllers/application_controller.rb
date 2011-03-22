class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :overall_trending
  
  def render_404
    render :text => File.read(Rails.root.to_s + '/public/404.html'), :status => 404
  end

  private
  def overall_trending
    @overall_trending= Deal.overall_trending
  end
end
