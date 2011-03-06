class SnapshotDiff < ActiveRecord::Base
  belongs_to :deal
  belongs_to :start_snapshot, :class_name => 'Snapshot'
  belongs_to :end_snapshot,   :class_name => 'Snapshot'
  
  class << self
    def total_spent
      all.sum(&:revenue_change)
    end
  end
end