class UrlCheck
  include GroupBuying::Mongoid::Doc
  
  field :url
  field :deal_exists,   :type => Boolean
  
  scope :current,  lambda { where(time_gt_than(:created_at => 1.hours.ago.utc)) }
  
  validates_presence_of :url
  validates_inclusion_of :deal_exists, :in => [true, false]
end