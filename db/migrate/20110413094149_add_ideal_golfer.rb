class AddIdealGolfer < ActiveRecord::Migration
  def self.up
    Site.create(:name => 'IdealGolfer', :base_url => 'http://www.idealgolfer.com', :active => true, :source_name => "ideal_golfer")
  end

  def self.down
    if site = Site.find_by_source_name('ideal_golfer')
      site.destroy
    end
  end
end
