# app/models/user.rb
# frozen_string_literal: true

# This class represents a user in the application.
# Each user has a name, email, and password, and may have an attached image.
# Users can also have multiple comments associated with them.
class User < ApplicationRecord
  # Associations
  has_one_attached :image, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :ratings
  has_many :histories, dependent: :destroy

  has_many :notifications, foreign_key: :recipient_id ,dependent: :destroy

  # assciations with saved_movies
  has_many :saved_movies, dependent: :destroy
  has_many :movies, through: :saved_movies

  # Association related to Disscussion
  has_many :discussions, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :replies, dependent: :destroy

  has_many :activities, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :name, presence: true

  scope :search_by_name, ->(keyword) {
    where("LOWER(name) LIKE ?", "%#{keyword.downcase}%")
  }

  def saved_movies
    SavedMovie.where(user_id: self.id)
  end

  def self.non_admin_users
    where(admin: false)
  end
end
