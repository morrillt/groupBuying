class BaseImporter
  include ActiveModel::Validations
  
  attr_reader :deal_id, :attributes
  attr_writer :current_snapshot
  validates_presence_of :deal_id, :url, :status, :title, :buyers_count, :price, :original_price, :currency
  
  def parse
    unless @parsed
      attributes.each do |field, value|
        #puts "setting #{field}=#{value}"
        instance_variable_set "@#{field.to_sym}", value
      end
    end
    
    @parsed = true
  end
  
  def method_missing(sym, *args, &block)
    #puts "method_missing for #{sym}: #{args.inspect}"
    return unless deal_exists?
    
    if [:url, :title, :buyers_count, :currency, :location].include? sym
      attributes[sym]
    end
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
  
  def initialize(deal_id)
    @deal_id = deal_id
  end
  
  def site
    self.class.site
  end
  
  def doc
    if deal_exists?
      @doc ||= parse_doc
    end
  end
  
  def cached?
    current_snapshot.try(:cache_available)
  end
  
  def current_snapshot
    @current_snapshot ||= Snapshot.current.where(:url => url).first
  end
  
  def url
    base_url + deal_id.to_s
  end
  
  def deal_exists?
    true
  end
  
  def status
    deal_exists? ?
      deal_status :
      :nonexistent
  end
  
  def currency
    'USD'
  end
  
  def save_snapshot
    Snapshot.from_importer(self)
  end
  
  class << self
    def site
      Site.find_by_name(site_name) || raise("can't find site: #{site_name}!")
    end
    
    def site_name
      to_s.sub(/Importer$/, '').underscore
    end
    
    def divisions_for_import
      site.divisions.needs_import
    end
    
    def import_deals
      find_new_deals do |deal|
        deal.save_snapshot
      end
    end
  end
  
end