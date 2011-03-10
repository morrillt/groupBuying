class UrlCheck
  include GroupBuying::Mongoid::Doc
  
  field :url
  field :site_id,       :type => Integer
  field :deal_exists,   :type => Boolean
  field :failure_count, :type => Integer
  
  index :url, :unique => true
  
  def self.recheck_interval
    1.hours.ago.localtime
  end
  
  scope :current,  lambda { where(time_gt_than(:created_at => recheck_interval)) }
  
  validates_uniqueness_of :url
  validates_presence_of   :url, :site_id
  validates_inclusion_of  :deal_exists, :in => [true, false]
  
  def current?
    UrlCheck.recheck_interval < updated_at
  end
end