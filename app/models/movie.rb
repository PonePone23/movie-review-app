# app/models/movie.rb
# frozen_string_literal: true

# This class represents a movie in the application.
# Each movie has a name, review, release date, duration, image, genres, comments, and a user associated with it.
class Movie < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :review, presence: true
  validates :release_date, presence: true
  validates :duration, presence: true
  validates :image, presence: true
  validates :trailer_url, presence: true, url: true

  # Associations
  has_one_attached :image, dependent: :destroy
  has_and_belongs_to_many :genres
  has_many :comments, dependent: :destroy
  has_many :ratings
  belongs_to :user
  # association with saved_movies
  has_many :saved_movies, dependent: :destroy
  has_many :histories,dependent: :destroy

  # Validates at least one genre is associated with movie
  validate :at_least_one_genre_present

  scope :search_by_keyword, ->(keyword) {
    where("LOWER(name) LIKE :keyword OR LOWER(casts) LIKE :keyword OR LOWER(director) LIKE :keyword OR LOWER(country) LIKE :keyword",
          keyword: "%#{keyword.downcase}%")
  }

  scope :released_in_year, ->(year) {
    where("release_date LIKE ?", "%#{year}%")
  }

  #def release_date=(date)
  #  # If the input is in YYYY format
  #  if date =~ /\A\d{4}\z/
  #    super("01-01-#{date}")
  #  else
  #    super(date)
  #  end
  #end

  private

  def at_least_one_genre_present
    errors.add(:genres, 'must be present') if genres.empty?
  end

  #def release_date_cannot_be_in_the_future
  #  if release_date.present? && release_date > Date.today
  #    errors.add(:release_date, "can't be in the future")
  #  end
  #end

end
