# db/migrate/YYYYMMDDHHMMSS_create_activities.rb

class CreateActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :activities do |t|
      t.string :action
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
