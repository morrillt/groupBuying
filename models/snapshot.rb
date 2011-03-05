class Snapshot < ActiveRecord::Base
  belongs_to :deal
  
  before_validation :set_current_flag, :on => :create
  # TODO: implement
  # validate :only_one_current
  
  scope :current, where(:current => true)
  scope :by_day,  lambda { |day| where(:data_date => day) }
  
  def current_snapshot
    @current_snapshot ||= deal.snapshots.by_day(data_date).current.first
  end
  
  def set_current_flag
    unless current_snapshot and data_time > current_snapshot.data_time
      current_snapshot.try(:update_attribute, :current, false)
      self.current = true
    end
  end
end