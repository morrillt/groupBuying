class SiteInfo
  include Mongoid::Document
  
  field :tracked_active,              :type => Float
  field :deals_tracked,               :type => Float
  field :coupon_purchased,            :type => Float
  field :total_revenue,               :type => Float
  field :avg_coupon,                  :type => Float
  field :avg_price_per_deal,          :type => Float
  field :avg_revenue_per_deal,        :type => Float
  field :closed_today,                :type => Float
  field :closed_yesterday,            :type => Float
  field :closed_week,                 :type => Float
  field :purchased_today,             :type => Float
  field :purchased_yesterday,         :type => Float
  field :purchased_week,              :type => Float
  field :revenue_today,               :type => Float
  field :revenue_yesterday,           :type => Float
  field :avg_revenue_today,           :type => Float
  field :avg_revenue_yesterday,       :type => Float
  field :change_today_yesterday,      :type => Float
  field :change_yesterday,            :type => Float
  field :purchased_change_today,      :type => Float
  field :change_purchased_yesterday,  :type => Float
  
  
end