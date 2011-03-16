class Division < ActiveRecord::Base
  has_many :deals
  belongs_to :site
  
  validates_uniqueness_of :name
end
