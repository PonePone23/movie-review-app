# app/models/comment.rb
# frozen_string_literal: true

# This class represents comments made by users on movies.
class Comment < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :movie

  # Validations
  validates :description, presence: true, length: { minimum: 100, maximum:  600}
end
