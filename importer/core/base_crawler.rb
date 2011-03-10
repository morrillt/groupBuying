# a crawler just knows how to go through a sites URL space (or really, the variables within that space)
# it then hands off those variables to a deal snapshooter which can check if a deal exists at that URL
class BaseCrawler < BaseImporter
  def self.crawl_new_deals
    potential_deal_ids do |deal_id|
      snapshooter = site.snapshooter(deal_id)
      
      result = if snapshooter.existence_cached?
        :cached
      elsif snapshooter.update_or_create_url_check.deal_exists?
        snap = snapshooter.create_snapshot
        snap.status
      else
        :nonexistent
      end
      
      puts "checking #{snapshooter.url} - #{result}"
      result
    end
  end
end