module Chartable
  def activity_tracker(opts = {})
    ActivityTracker.new(self, opts)
  end
end