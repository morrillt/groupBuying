class Site < ActiveRecord::Base
  has_many  :deals
  has_many  :snapshot_diffs, :through => :deals
  
  def title
    read_attribute(:name).titleize
  end
end