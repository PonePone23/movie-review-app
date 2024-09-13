# app/models/discussion.rb
# frozen_string_literal: true

# This class represents discusssion made by users
class Discussion < ApplicationRecord
  # Validations
  validates :content, presence: true

  # Associations
  belongs_to :user
  has_many :reactions, dependent: :destroy
  has_many :replies, dependent: :destroy
end
