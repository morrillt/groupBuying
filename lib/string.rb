class String
  # taken from Rails
  def humanize
    self.gsub(/-/, " ").capitalize
  end
end
