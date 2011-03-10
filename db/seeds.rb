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

open_table = Site.find_by_name('open_table')
opentable_divisions.each do |name, part|
  open_table.divisions.create(:name => name, :url_part => [name, part].join("/"))
end

groupon = Site.find_by_name('groupon')
Groupon.divisions.each do |division|
  groupon.divisions.create(:name => division.name, :division_id => division.id)
end

Site.create(:name => 'kgb_deals',     :importer_class => 'KgbDeals')
Site.create(:name => 'living_social', :importer_class => 'LivingSocial')

Site.all.each{|s| s.update_attribute(:importer_class, s.name.camelize)}
Site.find_by_name('groupon').update_attribute(:importer_class, 'GrouponImporter')

homerun = Site.create(:name => 'home_run', :importer_class => 'HomeRun')
doc = Nokogiri::HTML(open('http://www.homerun.com'))
doc.search('.region-picker .vertical-list a').map{|e| e['href'][/\w+/] }.each do |url_part|
  homerun.divisions.create(:name => url_part.capitalize, :url_part => url_part)
end

# reset:
Mongoid.master.collections.reject { |c| c.name == 'system.indexes'}.each(&:drop)
Deal.delete_all

# soft reset
SnapshotDiff.delete_all
Snapshot.all.each{ |s| s.update_attriubte(:analyzed, false) } # TODO: can we do this w/o instantiating objects?