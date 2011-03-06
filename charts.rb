get "/chart" do
  @chart = Chart.new(params.slice('from', 'to').symbolize_keys)
  
  erb :chart
end

get '/summary' do
  
  @site       = Site.find_by_name(params['company']) || Site.first
  @deltas     = [] #Delta.generate(Deal.yesterday, Deal.today)
  @hot_deals  = @site.deals.hot.limit(10)
  
  erb :summary
end