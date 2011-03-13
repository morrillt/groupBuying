class Division < ActiveRecord::Base
  include Chartable
  
  belongs_to :site
  has_many :deals
  has_many :snapshot_diffs
  
  scope :needs_import, lambda { where(:last_checked_at.lt => 20.minutes.ago) }
  delegate :url, :to => :crawler
  
  def chart_name
    url_part || division_id
  end
  
  def snapshots
    @snapshots ||= Snapshot.where(:division_id => id)
  end
  
  def crawler
    @crawler ||= site.crawler.new(self)
  end
end