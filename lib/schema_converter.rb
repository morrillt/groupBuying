module OldSchema
  extend ActiveSupport::Concern
  
  included do
    set_table_name model_name.downcase
    
    scope :needs_conversion, where(:converted => false)
  end
  
  def convert
    site = Site.find_by_name(self.class.model_name.underscore)
    
    deal =   site.deals.find_by_slug_and_zip_code(deal_id, location)
    deal ||= site.deals.create(deal_attrs)
    
    deal.snapshots.create(snapshot_attrs)
    
    update_attribute(:converted, true)
  end
  
  def deal_attrs
    @deal_attrs ||= begin
      {
        :slug       => deal_id,
        :title      => title,
        :url        => urltext,
        :active     => status,
        :zip_code   => location,
        :value      => value,
        :price      => price,
        :currency   => currency,
      }
    end
  end
  
  def snapshot_attrs
    {:buyers_count => count.to_i, :imported_at => imported_at, :active => status}
  end
  
  # recombine datadate & time(holding the hour) into a datetime object
  def imported_at
    datadate.to_time.utc + time.hour.hours
  end
  
  def value
    valuetext[/[\d\.]+/]
  end
  
  def price
    pricetext[/[\d\.]+/]
  end
  
  def currency
    pricetext[/[a-zA-Z]+$/] || ("GBP" if pricetext.starts_with?('&pound;'))
  end
  
  # b/c it's not in all the tables
  def urltext
    read_attribute(:urltext)
  end
  
  module ClassMethods
    def convert
      needs_conversion.find_each(&:convert)
    end
  end
end

class Groupon     < ActiveRecord::Base; include OldSchema; end
class OpenTable   < ActiveRecord::Base; include OldSchema; end
class TravelZoo   < ActiveRecord::Base; include OldSchema; end
class TravelZooUk < ActiveRecord::Base; include OldSchema; end



# {"location"=>"95060", 
#   "title"=>"$11 for Movie Ticket for One and Unlimited Soda and Popcorn for Two People at The Nickelodeon ($27.50 Value)", 
#   "pricetext"=>"11.00USD", 
#   "time"=>Sat Jan 01 23:00:54 +0100 2000, 
#   "id"=>29433, 
#   "hotindex"=>0, 
#   "datadate"=>Sat, 26 Feb 2011, 
#   "count"=>"1826", 
#   "deal_id"=>"the-nickelodeon-1", 
#   "urltext"=>"http://www.groupon.com/deals/the-nickelodeon-1", 
#   "valuetext"=>"27.00USD"
#   "status"=>"0", 
#   "datetext"=>Tue, 01 Mar 2011, 
# }