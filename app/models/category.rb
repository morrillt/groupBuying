class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :deals, :through => :categorizations
  
  validates_presence_of :name   
  
  def parent
    self.class.find(parent_id) if parent_id != 0
  end       
  
  def full_name
    str = name
    str = "#{parent.name}(#{name})" if parent
  end
  
end