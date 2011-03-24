class AddSiteDivisionIdToDivisions < ActiveRecord::Migration
  def self.up
    add_column :divisions, :site_division_id, :string
    Division.reset_column_information
    groupon = Site.find_by_source_name('groupon')
    Groupon.divisions.each do |gd|
      division = groupon.divisions.find_by_name(gd.name)
      division.site_division_id = gd.id
      division.save
    end
  end

  def self.down
    remove_column :divisions, :site_division_id
  end
end
