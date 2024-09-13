class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.string :name
      t.text :review
      t.text :casts
      t.date :release_date
      t.string :country
      t.string :production
      t.string :director
      t.string :duration
      t.text :trailer_url
      t.integer :user_id
      t.integer :rating

      t.timestamps
    end
  end
end
