module SitesHelper
  def display_percent(s)
    s == "No data" ? "No data" : "% #{s}"
  end
end
