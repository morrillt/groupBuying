get "/chart" do
  @chart = Chart.new(params.slice('from', 'to').symbolize_keys)
  
  erb :chart
end

get '/summary/:company' do
  @site       = Site.find_by_name(params[:company]) || Site.first
  
  @activity       = @site.activity_block(params.slice('from', 'to').symbolize_keys)
  @past_activity  = @site.activity_block(:from => @activity.from - 1.day, :to => @activity.to - 1.day)
  
  @comparison = Comparison.new(@activity, @past_activity)
  @hot_deals  = @site.deals.hot.limit(10)
  
  erb :summary
end

get '/snapshots' do
  @snapshots = Snapshot.current.desc(:created_at).limit(50)
  
  haml :snapshots
end