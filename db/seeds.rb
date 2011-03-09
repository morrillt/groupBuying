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

@open_table = Site.find_by_name('open_table')
opentable_divisions.each do |name, part|
  @open_table.divisions.create(:name => name, :url_part => [name, part].join("/"))
end

@groupon = Site.find_by_name('groupon')
Groupon.divisions.each do |division|
  @groupon.divisions.create(:name => division.name, :division_id => division.id)
end

Site.create(:name => 'kgb_deals')
Site.create(:name => 'living_social')