class Fixnum
  def percent_change_from(start)
    return 0 if zero? or start.zero?
    
    (((self - start) / start.to_f) * 100).round(2)
  end
end