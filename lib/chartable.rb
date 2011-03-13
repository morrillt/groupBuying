module Chartable
  def activity_block(opts = {})
    ActivityBlock.new(opts.merge(:association_chain => self))
  end
end