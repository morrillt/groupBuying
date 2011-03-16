class Division < ActiveRecord::Base
  has_many :deals
  
  validates_uniqueness_of :name
end
