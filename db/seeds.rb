##############################
########## RESET #############
##############################
Mongoid.master.collections.reject { |c| c.name == 'system.indexes'}.each(&:drop)
(ActiveRecord::Base.connection.tables - ['schema_migrations']).each do |table|
  ActiveRecord::Base.connection.execute "DELETE FROM #{table}"
  ActiveRecord::Base.connection.execute "ALTER TABLE #{table} AUTO_INCREMENT=1"
end

#SnapshotDiff.delete_all
#Snapshot.all.each{ |s| s.update_attribute(:analyzed, false) };0 # TODO: can we do this w/o instantiating objects?

##############################
##############################
##############################

# TODO: standardize/move into crawler classes
opentable_divisions = {
    :atlanta                => :atl,
    :boston                 => :bos,
    :chicago                => :chi,
    :denver                 => :den,
    :losangeles             => :la,
    'minneapolis-st-paul'   => :msp,
    :newyork                => :ny,
    :philadelphia           => :phi,
    :sanfrancisco           => :sf,
    :washingtondc           => :dc,
  }

open_table = Site.create(:name => 'open_table')
opentable_divisions.each do |name, part|
  open_table.divisions.create(:name => name, :url_part => [name, part].join("/"))
end

groupon = Site.create(:name => 'groupon')
Groupon.divisions.each do |division|
  groupon.divisions.create(:name => division.name, :division_id => division.id)
end

%w(kgb_deals living_social home_run travel_zoo travel_zoo_uk).each do |site_name|
  site = Site.create(:name => site_name)
  site.crawler.import_divisions
end