require 'rubygems'
require 'sinatra'
require 'erb'
require 'fastercsv'
require 'ostruct'
require 'config/environment'
require 'models/groupon_deal'
require 'lib/string.rb'

get '/' do
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

  @hot_deals = GrouponDeal.unique[0..30].sort{ |a,b| b.hotness_index <=> a.hotness_index }.take(10)
  erb :index
end
