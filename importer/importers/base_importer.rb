class BaseImporter
  include ActiveModel::Validations
  
  attr_reader :deal_id
  attr_writer :current_snapshot
  validates_presence_of :deal_id, :url, :title, :buyers_count, :price, :value, :currency
  
  def method_missing(sym, *args, &block)
    puts "method_missing for #{sym}: #{args.inspect}"
    if [:url, :title, :buyers_count, :price, :value, :currency, :location].include? sym
      attributes[sym]
    end
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
      Site.find_by_name(site_name) || raise("can't find site!")
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