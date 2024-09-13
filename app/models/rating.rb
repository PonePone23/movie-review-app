# app/models/rating.rb
# frozen_string_literal: true

# This class represents ratings for movies.
class Rating < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :movie

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }

  def self.max_rating_for_user(user,movie)
    max_rating = where(user_id: user.id,movie_id: movie.id).maximum(:rating)
    max_rating ? [max_rating, 5].min : 0
  end
end
