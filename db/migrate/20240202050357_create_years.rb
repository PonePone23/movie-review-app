class CreateYears < ActiveRecord::Migration[7.1]
  def change
    create_table :years do |t|
      t.string :year

      t.timestamps
    end
  end
end
