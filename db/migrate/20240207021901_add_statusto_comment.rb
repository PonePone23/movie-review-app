class AddStatustoComment < ActiveRecord::Migration[7.1]
  def change
    add_column :comments, :status, :boolean, default: false
  end
end
