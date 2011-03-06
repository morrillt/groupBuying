get "/chart" do
  @chart = Chart.new(params.slice('from', 'to').symbolize_keys)
  
  erb :chart
end

get '/summary' do
  @sites      = Site.all
  @deltas     = [] #Delta.generate(Deal.yesterday, Deal.today)
  @hot_deals  = Deal.hot.limit(10)
  
  erb :summary
end