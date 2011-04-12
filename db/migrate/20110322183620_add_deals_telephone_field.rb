class AddDealsTelephoneField < ActiveRecord::Migration
  def self.up
    add_column :deals, :telephone, :string, :limit => 30
    
    base = Snapshooter::Base.new('anysource')
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

  def self.down
    remove_column :deals, :telephone
  end
end
