class AddYipitCategoriesToDeal < ActiveRecord::Migration
  def self.up
    add_column :deals, :yipit_categories, :text
  end

  def self.down
    remove_column :deals, :yipit_categories
  end
end
