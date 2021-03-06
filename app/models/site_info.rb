class SiteInfo
  include Mongoid::Document
  field :site_id,                     :type => Integer
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
  
  field :deals_closed,      :type => Hash
  field :coupons_purchased, :type => Hash
  field :revenue_by_periods,:type => Hash
  field :average_revenue,   :type => Hash   
  
  def site
    @site ||= Site.find(site_id)
  end
  
  def deals_closed_for(days)
    deals_closed[days.to_s]
  end
  
  def deals_closed_percent(days)
    unless deals_closed[days.to_s] == 0
      if deals_closed["prev_#{days}"] == 0
        "No data"
      else
        (((deals_closed[days.to_s] - deals_closed["prev_#{days}"]) / deals_closed["prev_#{days}"].to_f) * 100).round(2)
      end
    else
      "No data"
    end
  end

  def coupons_purchased_for(days)
    coupons_purchased[days.to_s] 
  end    
  
  def coupons_purchased_percent(days)
    unless deals_closed[days.to_s] == 0
      if coupons_purchased["prev_#{days}"] == 0
        "No data"
      else
        (((coupons_purchased[days.to_s] - coupons_purchased["prev_#{days}"]) / coupons_purchased["prev_#{days}"].to_f) * 100).round(2)
      end
    else
      "No data"
    end
  end
  
  def revenue_by_periods_for(days)
    revenue_by_periods[days.to_s]
  end
  
  def revenue_by_periods_percent(days)
    unless revenue_by_periods[days.to_s] == 0
      if revenue_by_periods["prev_#{days}"] == 0
        "No data"
      else
        (((revenue_by_periods[days.to_s] - revenue_by_periods["prev_#{days}"]) / revenue_by_periods["prev_#{days}"].to_f) * 100).round(2)
      end
    else
      "No data"
    end
  end
  
  def average_revenue_for(days)
    average_revenue[days.to_s]
  end                            
  
  def average_revenue_percent(days)
    unless average_revenue[days.to_s] == 0
      if average_revenue["prev_#{days}"] == 0
        "No data"
      else
        (((average_revenue[days.to_s] - average_revenue["prev_#{days}"]) / average_revenue["prev_#{days}"].to_f) * 100).round(2)
      end
    else
      "No data"
    end
  end
  
end