require 'sinatra'
require 'erb'
require 'fastercsv'
require 'ostruct'
require 'config/environment'
require 'models/groupon_deal'

get '/' do
  @active_count = GrouponDeal.active.count
  @deals_tracked = GrouponDeal.unique.count
  @total_coupons = GrouponDeal.num_coupons(:unique)
  @total_spent = GrouponDeal.spent(:unique)
  @average_revenue = GrouponDeal.average_revenue(:unique)
  @num_zip_codes = GrouponDeal.num_zip_codes

  @closed_today = GrouponDeal.today.closed.count
  @coupons_today = GrouponDeal.num_coupons(:today)
  @spent_today = GrouponDeal.spent(:today)
  @revenue_today = GrouponDeal.average_revenue(:today)
  erb :index
end
