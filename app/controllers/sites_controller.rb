class SitesController < ApplicationController
  # GET /sites
  # GET /sites.xml
  def index
    @chart = Chart.new
    @sites = Site.active

    @chart_data= Chart.hourly_renevue_by_site
    # puts @chart_data.inspect

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find_by_source_name(params[:id])
    # @data = Deal.get_info(@site)
    @data[:locations] = @site.divisions.all.length
    #active deals
    @data[:tracked_active] = Deal.find(:all, :conditions => {:site_id =>  @site.id, :active => true }).length
    
    # deals tracked to date
    @data[:deals_tracked] = Deal.find(:all,:conditions => {:site_id => @site.id}).length
    
    #coupones purchased to date
    # @data[:coupon_purchased] = 0

    #total revenue to date
    # @data[:total_revenue]

    #avg revenue per deal
    # @data[:avg_deal]
    
    # locations per site   

    
    # deal closed today
    @data[:closed_today] = Deal.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM deals WHERE active=0 AND DATE(created_at)=DATE(NOW()) and site_id = "+@site.id.to_s).first.closed
    
    #deals closed yesterday
    @data[:closed_yesterday] = Deal.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 AND DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id ="+@site.id.to_s).first.closed

    #deals closed this week
    @data[:closed_week] = Deal.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 AND DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) AND DATE(created_at)<=DATE(NOW()) and site_id = "+ @site.id.to_s).first.closed

    #coupons purchased today
    @data[:purchased_today] = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)=DATE(NOW()) and site_id = " + @site.id.to_s).first.nsold.to_i

    #coupons purchased yesterday
    @data[:purchased_yesterday] = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = " + @site.id.to_s).first.nsold.to_i

    #coupons purchased week
    @data[:purchased_week] = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 7 DAY) and DATE(created_at)<=DATE(NOW()) and site_id = " + @site.id.to_s).first.nsold.to_i


    @chart = Chart.new([@site])
    

    respond_to do |format|

      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end
end
