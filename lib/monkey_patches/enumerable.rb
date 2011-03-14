module Enumerable
  def map_to_hash(s = {})
    inject(s) do |k, i|
      key, val = *yield(i).to_a.flatten
      k[key] = val
      k
    end
  end
end