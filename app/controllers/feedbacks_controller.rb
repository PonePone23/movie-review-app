# app/controllers/feedbacks_controller.rb
# frozen_string_literal: true

# This controller manages feedback submissions.
class FeedbacksController < ApplicationController
  # Renders the form for submitting new feedback.
  def new
    @feedback = Feedback.new
  end

  # Creates a new feedback submission.
  def create
    begin
      ActiveRecord::Base.transaction do
        @feedback = Feedback.new(feedback_params)
        respond_to do |format|
          if @feedback.save
            # Sends an email notification for the new feedback.
            FeedbackMailer.new_feedback(@feedback).deliver_now
            format.json { render json: { success: true } }
          else
            format.json { render json: { success: false, errors: @feedback.errors.messages } }
          end
        end
      end
    rescue StandardError => e
      # Handle the exception here
      Rails.logger.error("Error occurred while creating feedback: #{e.message}")
      raise ActiveRecord::Rollback # Rollback the transaction
    end
  end

  private

  # Defines the permitted parameters for a feedback submission.
  def feedback_params
    params.require(:feedback).permit(:name, :email, :message)
  end
end
