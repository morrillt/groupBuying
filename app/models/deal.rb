class Deal < ActiveRecord::Base
  
  # Associations
  has_many :snapshots
  belongs_to :site
  belongs_to :division
  
  # Validations
  validates_presence_of :name
  validates_presence_of :permalink
  validates_presence_of :price
  validates_presence_of :site
  validates_format_of :price, :with => /[0-9]/
  
  
  # Scopes
  scope :active, where(:active => true)
  
  before_create do
    # set a unique token
    self.token = Snapshooter::Base.tokenize(self)
  end
  
  # Instance Methods
  
  # Simply captures the snapshot data from the host
  # This method does not store anything
  # It is used to create snapshot records
  def capture_snapshot
    site.snapshooter.capture_deal(self)
  end


  # Creates an actual mysql record
  # Captures the most recent data for a deal.
  # This is run every n hours and used to visualize the deals progress.
  def take_snapshot!
    snapshots.create
  end
end
