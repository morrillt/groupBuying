get "/chart" do
  @chart = Chart.new(params.slice('from', 'to').symbolize_keys)
  
  erb :chart
end

get '/summary/:company' do
  @site       = Site.find_by_name(params[:company]) || Site.first
  @comparison = Comparison.new(params.slice('from', 'to').symbolize_keys.merge(:site => @site))
  @hot_deals  = @site.deals.hot.limit(10)
  
  erb :summary
end