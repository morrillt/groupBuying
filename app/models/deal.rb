class Deal < ActiveRecord::Base
  
  # Associations
  has_many :snapshots
<<<<<<< HEAD
  belongs_to :division
  belongs_to :site
=======
  belongs_to :site
  belongs_to :division
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
  
  # Validations
  validates_presence_of :name
  validates_presence_of :permalink
<<<<<<< HEAD
  validates_presence_of :actual_price
  validates_presence_of :sale_price
=======
  validates_presence_of :price
  validates_presence_of :site
  validates_format_of :price, :with => /[0-9]/
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
  
  
  # Scopes
  scope :active, where(:active => true)
  
<<<<<<< HEAD
  # Instance Methods

  def revenue
    @revenue ||= (buyers_count.to_f * sale_price.to_f)
  end
  
  # Returns the latest snapshots sold_count value
  def buyers_count
    @buyers_count ||= snapshots.last.try(:sold_count).to_i
  end
=======
  before_create do
    # set a unique token
    self.token = Snapshooter::Base.tokenize(self)
  end
  
  # Instance Methods
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
  
  # Simply captures the snapshot data from the host
  # This method does not store anything
  # It is used to create snapshot records
  def capture_snapshot
    site.snapshooter.capture_deal(self)
  end
<<<<<<< HEAD
  
  # Currently only kind
  def currency
    "USD"
  end
  
  # Returns the site record through the last division
  # same for all
  def site
    @site ||= division.site
  end
=======
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0


  # Creates an actual mysql record
  # Captures the most recent data for a deal.
  # This is run every n hours and used to visualize the deals progress.
  def take_snapshot!
<<<<<<< HEAD
    snapshots.create!(:site_id => self.site_id)
=======
    snapshots.create
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
  end
end
