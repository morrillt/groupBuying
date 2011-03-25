class HourlyRevenueByDivision
  include Mongoid::Document
  field :site_id, :type => Integer
  field :division_id, :type => Integer
  field :revenue, :type => Hash
  
end
