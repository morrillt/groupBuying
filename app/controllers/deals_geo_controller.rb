class DealsGeoController < ApplicationController
  layout "dealsgeo"

  def index
    [40.79513 -73.96331]
    @divs= "'/local-deals/New-York-City/deals', 'http://www.travelzoo.com/local-deals/New-York-City/deals', 'New York City', 'new-york', 'North Jersey', 'New York'"

    @deals= Deal.joins(:site, :division) \
      .select("deals.*, sites.source_name, divisions.name AS division") \
      .where("lat IS NOT NULL AND lat NOT IN(0.0) AND lng IS NOT NULL AND lng NOT IN(0.0) AND divisions.name IN(#{@divs})", :active => 1) \
      .order("updated_at DESC") \
      .group("permalink") \
      .limit(25)
  end
end
