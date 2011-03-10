class BaseImporter
  def site
    self.class.site
  end
  
  class << self
    def site
      Site.find_by_name(site_name) || raise("can't find site: #{site_name}!")
    end
    
    def site_name
      to_s.sub(/(Crawler|Snapshooter|Importer)$/, '').underscore
    end
    
    def divisions_for_import
      site.divisions.needs_import
    end
  end
  
end