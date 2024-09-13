# app/controller/activites_controller.rb
# frozen_string_literal: true

# This controller manages activites related to movies.
class ActivitiesController < ApplicationController
  def index
    @users = User.all
    @activities = Activity.all
  end

  # DELETE /activities/delete_all
  def delete_all
    activities =  Activity.all
    if activities.present?
      Activity.destroy_all
      redirect_to dashboard_users_path, notice: 'All activities have been deleted.'
    else
      redirect_to dashboard_users_path, notice: 'No activities to be deleted.'
    end
  end

  # DELETE /activities/:id/delete_single
  def delete_single
    @activity = Activity.find_by(id:params[:id])
    @activity.destroy
    redirect_to dashboard_users_path, notice: 'Activity has been deleted.'
  end

    # DELETE /users/:user_id/activities/delete_all
    def delete_user_activities
      user = User.find_by(id: params[:user_id])
      activities = Activity.find_by(user_id:params[:user_id])
      if user.present?
        if activities.present?
          user.activities.destroy_all
          redirect_to dashboard_users_path, notice: 'All activities for the user have been deleted.'
        else
          redirect_to filter_by_user_users_path, notice: 'No activities to be deleted.'
        end
      else
        redirect_to dashboard_users_path, notice: 'User not found.'
      end
    end

    def export
      @activities = Activity.all
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet :name => 'User Activities'
      sheet1.row(0).concat %w{Name Email Activity Time}
  
      @activities.each_with_index do |activity, index|
        user = activity.user
        activity_time = activity.created_at.in_time_zone('Rangoon').strftime("%I:%M:%S %p %A, %B %d, %Y")
        sheet1.row(index + 1).replace [user.name, user.email, activity.action.capitalize, activity_time]
      end
  
      blob = StringIO.new
      book.write blob
      blob.rewind
  
      send_data blob.read, filename: "user_activities.xls", type: "application/vnd.ms-excel"
    end
  
end
