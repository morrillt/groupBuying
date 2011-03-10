get "/chart" do
  @chart  = Chart.new(params.slice('from', 'to').symbolize_keys)
  @sites  = Site.active
  haml :chart
end

get '/summary/:site_name' do
  @site       = Site.find_by_name(params[:site_name]) || Site.first
  
  @activity       = @site.activity_block(params.slice('from', 'to').symbolize_keys)
  @past_activity  = @site.activity_block(:from => @activity.from - 1.day, :to => @activity.to - 1.day)
  
  @comparison = Comparison.new(@activity, @past_activity)
  @hot_deals  = @site.deals.hot.limit(10)
  
  haml :summary
end

get '/snapshots/:site_name' do
  @site       = Site.find_by_name(params[:site_name]) || Site.first
  @snapshots  = @site.snapshots.desc(:created_at).limit(100)
  
  haml :snapshots
end

get '/deals/:id' do
  @deal = Deal.find(params[:id])
  
  haml :deal
end