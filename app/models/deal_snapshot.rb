class DealSnapshot
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Fields
  field :site_id, :type => Integer
  field :deal_id, :type => Integer
  field :buyers_count, :type => Integer
  field :last_buyers_count, :type => Integer
  
  # Validations
  validates_presence_of :buyers_count
  
  # Callbacks
  before_save :populate_values
  
  private
  
  def populate_values
    deal = Deal.find(self.deal_id)
    # Capture the last buyers_count value
    self.last_buyers_count = self.class.where({:deal_id => deal.id}).order(:created_at.asc).last.try(:buyers_count).to_i
    # Store the site id in the snapshot table for easy reference
    self.site_id = deal.site_id
  end
end
  