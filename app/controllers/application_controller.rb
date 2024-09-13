# app/controller/application_controller.rb
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_feedback

  private

  def authenticate_admin!
    redirect_to root_path, alert: 'You are not authorized to access this page' unless current_user.admin?
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name,:image])
  end

  private
  # Sets the feedback instance variable
  def set_feedback
    @feedback = initialize_feedback
  end

  def initialize_feedback
    begin
      Feedback.new
    rescue StandardError => e
      Rails.logger.error("Error occurred while setting feedback: #{e.message}")
      nil # Return nil or handle the error as needed
    end
  end
end
