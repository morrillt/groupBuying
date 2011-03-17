class Division < ActiveRecord::Base
  has_many :deals
<<<<<<< HEAD
  belongs_to :site
=======
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
  
  validates_uniqueness_of :name
end
