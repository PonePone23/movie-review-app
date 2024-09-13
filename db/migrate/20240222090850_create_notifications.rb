class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false
      t.references :actor, null: false
      t.string :action
      t.references :notifiable, polymorphic: true, null: false

      t.timestamps
    end

    add_foreign_key :notifications, :users, column: :recipient_id
    add_foreign_key :notifications, :users, column: :actor_id
  end
end
