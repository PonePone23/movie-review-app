class CreateReplies < ActiveRecord::Migration[7.1]
  def change
    create_table :replies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :discussion, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
