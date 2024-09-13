# app/modles/year.rb
# frozen_string_literal: true

# This class represents year.
class Year < ApplicationRecord
  # Validations
  validates :year, presence: true , uniqueness: true
  scope :search_by_year, ->(keyword) {
    where("year LIKE ?", "%#{keyword}%")
  }
end
