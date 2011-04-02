namespace :routines do
  
  # rake routines:divisions:update_travel_zoo_divisions
  namespace :divisions do
    desc 'Renames the divisions to the correct name'
    task :update_travel_zoo_divisions => :environment do
      if site = Site.find_by_source_name('travel_zoo')
        site.divisions.each do |division|
          division.name = division.url.scan(/\/local-deals\/(.+)\/deals/i).try(:first).to_s.gsub(/\-/,' ')
          unless division.name.blank?
            p = division.save
            division.destroy unless p # Destroy equal divisions
            puts "Updating #{division.name} #{p}"
          end
        end
      end
    end
    
    # rake routines:divisions:update_open_table_divisions
    desc 'Renames the divisions to the correct name'
    task :update_open_table_divisions => :environment do
      if site = Site.find_by_source_name('open_table')
        site.divisions.each do |division|
          division.name = division.url.split("/").try(:last).to_s.titlecase
          unless division.name.blank?
            division.save
            puts "Updating #{division.name}"
          end
        end
      end
    end
  end
    
  desc "split raw_addess and telephones"
  task :split_raw_address  => :environment do
    base = Snapshooter::Base.new
    Deal.all.each {|d|
      if d.raw_address
        address, telephone = base.split_address_telephone(d.raw_address)
        if telephone
          d.raw_address = address
          d.telephone = telephone
          d.save(false)
        end
      end
    } 
  end 
  
  namespace :deals do 
    desc "update expired deals data"
    task :update_expired_deals => :environment do
      Site.all.each {|site|
        site.update_expired_deals
      }
    end
  end
end