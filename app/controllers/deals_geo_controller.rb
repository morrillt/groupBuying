class DealsGeoController < ApplicationController
  layout "dealsgeo"

  def index
    # @divs= "'/local-deals/New-York-City/deals', 'http://www.travelzoo.com/local-deals/New-York-City/deals', 'New York City', 'new-york', 'North Jersey', 'New York'"
    @divs= "'/local-deals/Los-Angeles-Area/deals', 'http://www.travelzoo.com/local-deals/Los-Angeles-Area/deals', 'Los Angeles', 'los-angeles'"

    @deals= Deal.joins(:site, :division) \
      .select("deals.*, sites.source_name, divisions.name AS division") \
      .where("lat IS NOT NULL AND lat NOT IN(0.0) AND lng IS NOT NULL AND lng NOT IN(0.0)", :active => 1) \
      .order("created_at DESC") \
      .group("permalink") \
      .limit(50)
    # AND divisions.name IN(#{@divs})
  end
  
  # receive address to geocode it
  def geocode
    address= URI.escape(params[:address], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    url= "http://maps.googleapis.com/maps/api/geocode/json?address=#{address}&sensor=false"
    json= JSON.parse RestClient.get(url)
    respond_to do |format|
      format.json { render :json => json,  :layout => false }
    end
  end
end
