class AddParentIdToCategories < ActiveRecord::Migration
  def self.up  
    add_column :categories, :parent_id, :integer, :default => 0
    remove_column :deals, :yipit_categories
  end

  def self.down                                 
    remove_column :categories, :parent_id
    add_column :deals, :yipit_categories, :text
  end
end
