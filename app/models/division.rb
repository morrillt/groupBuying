class Division < ActiveRecord::Base
  has_many :deals, :dependent => :destroy
  belongs_to :site
  
  validates_uniqueness_of :name, :scope => :site_id
end
