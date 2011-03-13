# a crawler just knows how to go through a sites URL space (or really, the variables within that space)
# it then hands off those variables to a deal snapshooter which can check if a deal exists at that URL
class BaseCrawler < BaseImporter
  class << self
    def import_divisions
      find_divisions.each do |url_part|
        next if site.divisions.exists?(:url_part => url_part)
        site.divisions.create!(:url_part => url_part, :name => url_part.capitalize)
      end
    end
    
    def find_divisions
      extract_from_links(possible_division_links, division_link_regex)
    end
    
    # takes a collection of Nokogiri a elements and extracts the w/ the supplied regex
    def extract_from_links(elements, regex)
      elements.map do |e|
        href = e['href']
        #puts "checking #{href} against #{regex}"
        href.match(regex).try(:[], 1)
      end.compact.uniq
    end
    
    # TODO: DRY up url-loading across classes
    def divisions_doc
      @divisions_doc ||= parse_url(division_list_url)
    end
    
    def crawl_new_deals
      potential_deal_ids do |*deal_id_with_optional_args|
        deal_id, args = *deal_id_with_optional_args
        args ||= {}

        snapshooter = site.snapshooter(deal_id)

        result = if snapshooter.existence_cached?
          :cached
        elsif snapshooter.update_or_create_url_check.deal_exists?
          snap = snapshooter.create_snapshot(args)
          snap.status
        else
          :nonexistent
        end

        puts "checking #{snapshooter.url} - #{result}"
        result
      end
    end
  end
  
  attr_reader :division
  def initialize(division)
    @division = division
  end
end