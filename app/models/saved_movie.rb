# app/models/saved_movie.rb
# frozen_string_literal: true

# This class represents saved_movies of a user.
class SavedMovie < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :movie
end
