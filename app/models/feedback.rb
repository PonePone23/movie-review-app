# app/models/feedback.rb
# frozen_string_literal: true

# This class represents feedback submitted by users.
# Feedback can include the name, email, and a message.
class Feedback < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true
end
