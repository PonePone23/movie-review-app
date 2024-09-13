# app/models/reply.rb
# frozen_string_literal: true

# This class represents replie of a discussion made by a user.
class Reply < ApplicationRecord
  # Validations
  validates :content, presence: true

  # Associations
  belongs_to :user
  belongs_to :discussion
end
