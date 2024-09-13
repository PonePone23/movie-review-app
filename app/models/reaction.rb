# app/models/reaction.rb
# frozen_string_literal: true

# This class represents reaction of discussion made by a user.
class Reaction < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :discussion

  # Validations
  validates :reaction_type, presence: true

  def user_name
    user.name if user
  end
end
