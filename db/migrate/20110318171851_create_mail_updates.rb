class CreateMailUpdates < ActiveRecord::Migration
  def self.up
    create_table :mail_updates do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :mail_updates
  end
end
