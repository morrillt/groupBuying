class TrendsController < ApplicationController
  def index
    @by_revenue= Deal.current_revenue_trending
    @by_hotness= Deal.overall_trending(25)
    respond_to do |format|
      format.html
    end
  end
end
