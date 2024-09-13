# app/controllers/notifications_controller.rb
# frozen_string_literal: true

# This controller manages Notifiactions related to users.
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  def index
    current_user.activities.create(action:"Browsed Notifications Page")
    @notifications = Notification.where(recipient_id: current_user.id).order(created_at: :desc).page(params[:page]).per(5)
  end

  # Method to delete all notifications related to the current user
  def delete_all
    notifications = Notification.where(recipient_id: current_user.id)
    if notifications.present?
      notifications.destroy_all
      redirect_to notifications_path, notice: 'All notifications have been deleted.'
      current_user.activities.create(action:"Dismiss all notifications")
    else
      redirect_to notifications_path, alert: 'No notifications found to delete.'
    end
  end


  # Method to delete notification
  def destroy
    begin
      @notification = Notification.find(params[:id])
      @notification.destroy
      redirect_to notifications_path, notice: 'Notification has been deleted.'
      current_user.activities.create(action:"Delete notification.")
    rescue ActiveRecord::RecordNotFound
      redirect_to notifications_path, alert: 'Notification not found.'
    end
  end


  # Method to get the ID of the admin user
  def admin_user_id
    admin_user = User.find_by(admin: 1)
    admin_user.id if admin_user
  end
end
