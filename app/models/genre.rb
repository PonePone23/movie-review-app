# app/models/genres.rb
# frozen_string_literal: true

# This class represents a genre of movies.
# Each genre has a unique name and can be associated with multiple movies.
class Genre < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validate :name_does_not_contain_digits
  # Associations
  has_and_belongs_to_many :movies

  scope :search_by_name, ->(keyword) {
    where("LOWER(name) LIKE :keyword", keyword: "%#{keyword.downcase}%")
  }
  private
  def name_does_not_contain_digits
    if name.present? && name.match?(/\d/)
      errors.add(:name, "can't consist of only digits")
    end
  end
end
