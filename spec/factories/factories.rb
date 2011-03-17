Factory.define(:deal) do |f|
  f.name "A great deal"
  f.permalink "http://someurl.com"
  f.actual_price 1.99
  f.sale_price 0.99
  f.division{ Factory(:division) }
end

Factory.define(:site) do |f|
  f.source_name 'kgb_deals'
end

Factory.define(:division) do |f|
  f.site{ Factory(:site) }
end

Factory.define(:snapshot) do |f|
  f.site{ Factory(:site) } 
  f.deal{ Factory(:deal) }
end