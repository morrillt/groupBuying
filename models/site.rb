class Site < ActiveRecord::Base
  has_many  :divisions
  has_many  :deals
  has_many  :snapshot_diffs, :through => :deals
  
  scope :active,  where(:active => true)
  
  def importer
    importer_class.constantize
  end
  
  def title
    read_attribute(:name).titleize
  end
  
  def activity_block(opts = {})
    ActivityBlock.new(opts.merge(:association_chain => self))
  end
end