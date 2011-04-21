class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :deals, :through => :categorizations
  
  validates_presence_of :name
end
