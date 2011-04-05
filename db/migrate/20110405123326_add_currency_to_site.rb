class AddCurrencyToSite < ActiveRecord::Migration
  def self.up 
    add_column :sites, :currency, :integer, :default => 0
    
    # Update sites currencies
    Site.all.each {|site|
      case site.source_name
        when 'travel_zoo_uk'
          site.currency = 1
        else
          site.currency = 0
      end
      site.save
    }
  end

  def self.down
    remove_column :sites, :currency
  end
end
