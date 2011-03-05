get '/groupon' do
  @sites      = Site.all
  @deltas     = Delta.generate(Deal.yesterday, Deal.today)
  @hot_deals  = Deal.hot_deals
  
  erb :groupon
end

get "/chart" do
  @categories, @values = Deal.chart_data
  @categories = @categories.map { |c| "'#{c.to_s}'"}
#  @categories = []
#  @values = []
  @total = Deal.unique.count
  erb :chart
end