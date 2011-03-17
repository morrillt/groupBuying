# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Site.create(:name => "Kgb", 
            :base_url => "http://www.kgbdeals.com",
            :source_name => "kgb-deals",
            :active => true
            )

Site.create(:name => "Group On", 
            :base_url => "http://www.groupon.com",
            :source_name => "group-on",
            :active => true
            )

Site.create(:name => "Travel Zoo", 
            :base_url => "www.travelzoo.com",
            :source_name => "travel-zoo",
            :active => true
            )
Site.create(:name => "Home Run", 
            :base_url => "http://www.homerun.com",
            :source_name => "home-run",
            :active => true
            )
Site.create(:name => "Living Social", 
            :base_url => "http://deals.livingsocial.com",
            :source_name => "living-social",
            :active => true
            )
Site.create(:name => "Open Table", 
            :base_url => "http://www.opentable.com",
            :source_name => "open-table",
            :active => true
            )
Site.create(:name => "Travel Zoo UK", 
            :base_url => "http://www.travelzoo.com/uk",
            :source_name => "travel-zoo-uk",
            :active => true
            )
