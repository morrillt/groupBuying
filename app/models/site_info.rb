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
  
  field :deals_closed,      :type => Hash
  field :coupons_purchased, :type => Hash
  field :revenue_by_periods,:type => Hash
  field :average_revenue,   :type => Hash   
  
  def deals_closed_for(days)
    deals_closed[days.to_s]
  end
  
  def deals_closed_percent(days)
    unless deals_closed[days.to_s] == 0
      if deals_closed["prev_#{days}"] == 0
        # deals_closed[days]
        "No data"
      else
        ((deals_closed[days].to_i - deals_closed["prev_#{days}"].to_i) / deals_closed["prev_#{days}"]) * 100
      end
    else
      "No data"
    end
  end

  def coupons_purchased_for(days, previous = false)   
    coupons_purchased[days.to_s] 
  end    
  
  def coupons_purchased_percent(days)
    unless deals_closed[days.to_s] == 0
      if coupons_purchased["prev_#{days}"] == 0
        # coupons_purchased[days]
        "No data"
      else
        ((coupons_purchased[days].to_i - coupons_purchased["prev_#{days}"].to_i) / coupons_purchased["prev_#{days}"]) * 100
      end
    else
      "No data"
    end
  end
  
  def revenue_by_periods_for(days, previous = false)
    revenue_by_periods[days.to_s]
  end
  
  def revenue_by_periods_percent(days)
    unless revenue_by_periods[days.to_s] == 0
      if revenue_by_periods["prev_#{days}"] == 0
        # revenue_by_periods[days]
        "No data"
      else
        ((revenue_by_periods[days].to_i - revenue_by_periods["prev_#{days}"].to_i) / revenue_by_periods["prev_#{days}"]) * 100
      end
    else
      "No data"
    end
  end
  
  def average_revenue_for(days, previous = false)
    average_revenue[days.to_s]
  end                            
  
  def average_revenue_percent(days)
    unless average_revenue[days.to_s] == 0
      if average_revenue["prev_#{days}"] == 0
        # average_revenue[days]
        "No data"
      else
        ((average_revenue[days].to_i - average_revenue["prev_#{days}"].to_i) / average_revenue["prev_#{days}"]) * 100
      end
    else
      "No data"
    end
  end
  
end