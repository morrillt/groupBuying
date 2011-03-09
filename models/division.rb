class Division < ActiveRecord::Base
  belongs_to :site
  has_many :deals
  
  scope :needs_import, lambda { where(:last_checked_at.lt => 20.minutes.ago) }
end