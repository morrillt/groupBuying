module Chartable
  def activity_tracker(opts = {})
    ActivityBlock.new(self, opts)
  end
end