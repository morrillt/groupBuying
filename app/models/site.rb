class Site < ActiveRecord::Base
  include Chartable
  
  has_many  :divisions
  has_many  :deals
  has_many  :snapshot_diffs
  
  scope :active,            where(:active => true)
  
  def to_param
    name
  end
  
  def crawler
    @crawler ||= "#{name.camelize}Crawler".constantize
  end
  
  def snapshooter(deal_id)
    @crawler ||= "#{name.camelize}Snapshooter".constantize.new(deal_id)
  end
  
  def snapshots
    @snapshots ||= Snapshot.where(:site_id => id)
  end
  
  def url_checks
    @url_checks ||= UrlCheck.where(:site_id => id)
  end
  
  def chart_name
    title
  end
  
  def title
    read_attribute(:name).titleize
  end
end