class HourlyRevenueBySite
  include Mongoid::Document
  field :site_id, :type => Integer
  field :revenue, :type => Hash
end
