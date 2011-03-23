namespace :routines do
  
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
  
end