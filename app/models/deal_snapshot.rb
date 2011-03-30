class DealSnapshot
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Fields
  field :site_id, :type => Integer
  field :deal_id, :type => Integer
  field :division_id, :type => Integer
  field :buyers_count, :type => Integer
  field :last_buyers_count, :type => Integer
  
  # Validations
  validates_presence_of :buyers_count
  
  # Scopes
  
  def self.by_date_range(from, to, conditions = {})
    query = {:created_at.gte => from, :created_at.lte => to}
    where(query.merge!(conditions))#.to_a
  end
  
  def self.recent
    where({:created_at.gte => 1.day.ago.at_midnight}).order(:created_at.asc).to_a
  end
  
  def total_revenue
    (price.to_f * buyers_count.to_f)
  end
  
  def price
    @price ||= deal.try(:sale_price).to_f
  end
  
  def deal_name
    @deal_name ||= self.deal.name
  end
  
  def site_name
    @site_name ||= self.site.name
  end

  def site
    @site ||= Site.find(site_id)
  end
  
  def deal
    @deal ||= Deal.find(deal_id) rescue nil
  end
  
  def self.last_recorded_buyers_count_for_deal(deal)
    where({:deal_id => deal.id}).order(:created_at.asc).last.try(:buyers_count).to_i
  end
  
  def self.create_from_deal!(deal)
    if deal.expires_at <= Time.now
      deal.close!
      return false
    end
    this = new
    this.deal_id = deal.id
    # Capture hotness of deal
    this.deal.calculate_hotness!
    # Capture the buyers count from the deal
    this.buyers_count = deal.capture_sold_count# - 35 < 0) ? 0 : deal.capture_sold_count - 35
    # Capture the last buyers_count value
    this.last_buyers_count = last_recorded_buyers_count_for_deal(this.deal)
    # Store the site id in the snapshot table for easy reference
    this.site_id = deal.site_id
    # Store the division id from the deal for metrics
    this.division_id = deal.division_id
    # this.created_at = Time.now - 5.hours
    this.save
    
    deal.max_sold_count ||= 0
    if deal.max_sold_count < this.buyers_count
      deal.max_sold_count = this.buyers_count
      deal.save
    end
  end
  
  # Returns an Float of the percent changed
  # from last_buyers_count to sold_count
  def upsell_diff
    last_buyers_count.percent_change_from(buyers_count)
  end
end
  