class AddSiteDivisionIdToDivisions < ActiveRecord::Migration
  def self.up
    # hack
    unless Division.new.respond_to?(:site_division_id)
      add_column :divisions, :site_division_id, :string
      Division.reset_column_information
    end
    groupon = Site.find_by_source_name('groupon')
    Groupon.divisions.each do |division|
      puts "Adding division #{division.id}"
      
      if division = groupon.divisions.find_or_initialize_by_name(division.name)
        division.site_division_id = division.id
        division.save
      end
    end
  end

  def self.down
    if Division.new.respond_to?(:site_division_id)
      remove_column :divisions, :site_division_id
    end
  end
end
