# a snapshooter basically knows where to find a remote representation of a deal based on it's ID
# it can check if the deal exists, and if so fetch the data and parse it into the fields we need
class BaseSnapshooter < BaseImporter
  include ActiveModel::Validations
  
  # monkey-patching ActiveModel's #valid? to make sure we've parsed the document before we run it
  def valid?(context = nil)
    parse!
    super(context)
  end
    
  def self.required_deal_fields
    [:deal_id, :url, :status, :title, :buyers_count, :price, :original_price, :currency]
  end
  
  def self.optional_deal_fields
    [:location]
  end
  
  def self.all_deal_fields
    required_deal_fields + optional_deal_fields
  end
  
  attr_writer :current_snapshot, :use_caching
  attr_accessor *(all_deal_fields + [:discount])
  validates_presence_of required_deal_fields
  
  def initialize(deal_id)
    @deal_id = deal_id
  end
  
  def url
    base_url + deal_id.to_s
  end
  
  def total_revenue
    buyers_count * price if valid?
  end
  
  def parse!
    return if @parsed
    
    attributes.each do |field, value|
      self.send("#{field}=", value)
    end
    
    @parsed = true
  end
  
  def deal_exists?
    if @deal_exists.nil?
      @exists = existence_cached? || existence_check
    else
      @deal_exists
    end
  end
  
  def existence_cached?
    !!(current_url_check || current_snapshot)
  end
  
  def use_caching?
    @use_caching != false
  end
  
  def cached?
    !! use_caching? and current_snapshot
  end
  
  def current_url_check
    @current_url_check ||= site.url_checks.where(:url => url).first
  end
  
  def current_snapshot
    @current_snapshot ||= site.snapshots.current.where(:url => url).first
  end
  
  def update_or_create_url_check
    url_check = (current_url_check || site.url_checks.new(:url => url, :site_id => site.id))
    url_check.update_attributes!(:deal_exists => existence_check)
    
    url_check
  end
  
  def create_snapshot(opts = {})
    # never create a new snapshot with cached (i.e. old snapshot) data
    self.use_caching = false
    snapshot = site.snapshots.create(snapshot_attrs.merge(opts))
    self.use_caching = true
    snapshot
  end
  
  def snapshot_attrs
    @snapshot_attrs ||= {
      :url        => url,
      :site_id    => site.id,
      :deal_id    => deal_id,
      :raw_data   => raw_data,
      :status     => status,
      :valid_deal => valid?,
    }
  end
  
  def deal_attrs
    @deal_attrs ||= begin
      parse!
      
      attrs = {}
      self.class.all_deal_fields.each do |field|
        attrs[field] = send(field)
      end
      attrs
    end
  end
  
  def status
    deal_exists? ?
      deal_status :
      :nonexistent
  end
  
  def currency
    'USD'
  end
  
  def price
    @price || calculate_price_from_rest
  end
  
  def original_price
    @original_price || calculate_value_from_rest
  end
  
  def calculate_price_from_rest
    return nil unless @original_price and @discount
    @original_price * ((100 - @discount) / 100)
  end
  
  def calculate_value_from_rest
    return nil unless @price and @discount
    @price / ((100 - @discount) / 100)
  end
end