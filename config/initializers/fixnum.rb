class Fixnum
  def percent_change_from(start)
    return 0 if zero? or start.zero?
    return (((self.to_f - start) / self.to_f) * 100)
  end
end