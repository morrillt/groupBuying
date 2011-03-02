require 'rubygems'
require 'sinatra'
require 'erb'
require 'fastercsv'
require 'ostruct'
require 'config/environment'
require 'models/groupon_deal'
require 'lib/string.rb'

get '/groupon' do
  @active_count = GrouponDeal.active.length
  @deals_tracked = GrouponDeal.unique.length
  @total_coupons = GrouponDeal.num_coupons
  @total_spent = GrouponDeal.spent(:unique)
  @average_revenue = GrouponDeal.average_revenue(:unique)
  @num_zip_codes = GrouponDeal.zip_codes.count

  @closed_today = GrouponDeal.today.closed.length
  @coupons_today = GrouponDeal.num_coupons(:today)
  @spent_today = GrouponDeal.spent(:today)
  @revenue_today = GrouponDeal.average_revenue(:today)
  calculate_daily_changes

  @hot_deals = GrouponDeal.unique[0..30].sort{ |a,b| b.hotness_index <=> a.hotness_index }.take(10)
  erb :groupon
end

get "/groupbuying" do
  @categories, @values = GrouponDeal.chart_data
  @categories = @categories.map { |c| "'#{c.strftime('%a %d')}'"}
  @total = GrouponDeal.unique.length
  erb :chart
end

def calculate_daily_changes
  @closed_change = GrouponDeal.change(GrouponDeal.yesterday.closed.length, @closed_today)
  @coupons_change = GrouponDeal.change(GrouponDeal.num_coupons(:yesterday), @coupons_today)
  @spent_change = GrouponDeal.change(GrouponDeal.spent(:yesterday), @spent_today)
  @revenue_change = GrouponDeal.change(GrouponDeal.average_revenue(:yesterday), @revenue_today)
end
