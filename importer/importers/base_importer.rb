class BaseImporter
  include ActiveModel::Validations
  
  validates_presence_of :deal_id, :url, :title, :buyers_count, :price, :value, :currency
  attr_accessor :deal_id, :url, :title, :active, :price, :value, :discount, :currency, :buyers_count, :location
  
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
  
  def initialize(deal_id)
    @deal_id = deal_id
  end
  
  def site
    self.class.site
  end
  
  # we assume a deal exists. override this in the sub class to implement checking logic
  def exists?
    true
  end
  
  def currency
    'USD'
  end
  
  def save_snapshot
    Snapshot.from_importer(self)
  end
end