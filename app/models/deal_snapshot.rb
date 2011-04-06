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
  
  def self.coupons_purchased_by_given_period(from, to, site_id = nil)
    map = 'function() { 
      emit( this.deal_id, {min: this.last_buyers_count, max: this.buyers_count}
    )}'
    reduce = 'function(k, vals) {
      r = { min: vals[0].min, max: vals[0].max }
      for(var i=0; i < vals.length; i++) {
        if (vals[i].min < r.min) { r.min = vals[i].min }
        if (vals[i].max > r.max) { r.max = vals[i].max }
      }
      return r;
    }'
    finalize = 'function(key, val) {
      val.deals = val.max - val.min;
      return val;
    }'                   
    query = {:created_at => {"$gt" => from.utc, "$lt" => to.utc}}
    query.merge!({:site_id => site_id}) if site_id
    
    result = DealSnapshot.collection.mapreduce(map, reduce, :finalize => finalize, :query => query)
    
    deals = {}    
    result.find().to_a.each{ |d| 
      deals[d["_id"].to_i] = d["value"]["deals"] if d["value"] 
    }.compact
    deals
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
  
  def self.create_from_deal!(deal, first = nil)
    deal.close! if deal.expires_at <= Time.now
    this = new
    this.deal_id = deal.id
    # Capture hotness of deal
    this.deal.calculate_hotness!
    # Capture the buyers count from the deal
    this.buyers_count = deal.capture_sold_count
    # Capture the last buyers_count value
    # If first snapshot, then last_buyesr_count will be equal to buyers_count
    this.last_buyers_count = first ? this.buyers_count : last_recorded_buyers_count_for_deal(this.deal)
    # Store the site id in the snapshot table for easy reference
    this.site_id = deal.site_id
    # Store the division id from the deal for metrics
    this.division_id = deal.division_id
    this.save
    
    deal.max_sold_count ||= 0
    deal.update_attribute(:max_sold_count, this.buyers_count) if deal.max_sold_count != this.buyers_count && this.buyers_count > 0
  end
  
  # Returns an Float of the percent changed
  # from last_buyers_count to sold_count
  def upsell_diff
    last_buyers_count.percent_change_from(buyers_count)
  end
end
  