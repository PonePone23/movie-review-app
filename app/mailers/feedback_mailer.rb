# app/mailers/feedback_mailer.rb
# frozen_string_literal: true

# This is FeedbackMailer class responsible for sending emails related to feedback.
class FeedbackMailer < ApplicationMailer
  default to: -> { ENV.fetch("DEFAULT_EMAIL") }

  # Method to send a new feedback email
  def new_feedback(feedback)
    @feedback = feedback
    mail(from: feedback.email, to: ENV.fetch("DEFAULT_EMAIL"), subject: 'New Feedback Received')
  end
end
