class DealsGeoController < ApplicationController
  layout "dealsgeo"

  def index
    @deals= Deal.joins(:site).select("deals.*, sites.source_name").where("lat IS NOT NULL AND lat NOT IN(0.0) AND lng IS NOT NULL AND lng NOT IN(0.0)").limit(25)
  end
end
