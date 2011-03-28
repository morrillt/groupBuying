Factory.define(:site) do |f|
  f.source_name 'kgb_deals'
end

Factory.sequence(:deal_name) do |n|
  "A great deal #{n}"
end

Factory.define(:deal) do |f|
  f.name { Factory.next(:deal_name) }
  f.permalink "http://someurl.com"
  f.actual_price 1.99
  f.sale_price 0.99
  f.division{ Factory(:division) }
end

Factory.define(:division) do |f|
  f.name{ Factory.next(:deal_name) }
  f.site{ Factory(:site) }
end

Factory.define(:snapshot) do |f|
  f.site{ Factory(:site) } 
  f.deal{ Factory(:deal) }
  f.sold_count 10
end

Factory.define(:deal_snapshot) do |f|
  f.site_id{ Factory(:site).id } 
  f.deal_id{ Factory(:deal).id }
  f.buyers_count 10
end
