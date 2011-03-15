Factory.sequence(:id) do |n|
  (n*Time.now.to_i)
end

Factory.define(:deal) do |f|
  f.title "A deal"
  f.active false
  f.site_id{ Factory.next(:id) }
  f.deal_id{ Factory.next(:id) }
  f.price 5.00
  f.status 'active'
end

Factory.define :snapshot_diff do |f|
  f.snapshot_id{ Factory.next(:id) }
  f.old_snapshot_id{ Factory.next(:id) }
  f.closed false
  f.revenue_change 2.50
  f.buyer_change 3.50
  f.changed_at 1.minute.ago
end

Factory.define :snapshot do |f|
  f.url "http://example.com"
  f.site_id{ Factory.next(:id) }
  f.deal_id{ Factory.next(:id) }
  f.raw_data " some data "
  f.status "active"
end