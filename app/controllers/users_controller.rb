# app/controllers/users_controller.rb
# frozen_string_literal: true

# This controller manages user-related actions such as registration, update, and deletion.
class UsersController < ApplicationController
  before_action :set_feedback
  before_action :check_admin, except: [:saved_movies, :unsave, :delete_image]

  require 'spreadsheet'
  before_action :authenticate_user!, except: [:index, :show]
  # Displays a paginated list of users
  def index
    @users = User.order(:name).page(params[:page]).per(10)
  end

  ## Shows details of the specific user
  #def show
  #  @user = User.find(params[:id])
  #end

  # Renders the form for new user registration
  def new_registration
    @user = User.new
  end

  # Creates a new user registration
  def create_registration
    ActiveRecord::Base.transaction do
      @user = User.new(user_params)
      if /@admin\.com\z/.match?(@user.email)
        @user.admin = true
      end
      @user.admin = params[:user][:admin] == "true"

      respond_to do |format|
        if @user.save
          format.html { redirect_to users_path, notice: 'User was successfully created.' }
          format.json { render json: @user, status: :created, location: @user }
        else
          format.html { render :new_registration, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  rescue StandardError => e
    redirect_to new_registration_path, alert: 'Failed to create User. An error occurred while processing your request.'
    Rails.logger.error("Error occurred while creating user: #{e.message}")
    raise ActiveRecord::Rollback # Rollback the transaction
  end

  # Render the form of editing an existing user
  def edit
    @user = User.find(params[:id])
  end

  # Updats an existing user
  def update
    ActiveRecord::Base.transaction do
      @user = User.find(params[:id])
      @user.admin = params[:user][:admin] == "true"
      unless current_user == @user || current_user.admin?
        redirect_to root_path, notice: 'You do not have permission to update this user.'
        return
      end
      if user_params[:password].present?
        if @user.update(user_params)
          redirect_to users_path, notice:"User was successfully updated!"
        else
          render :edit
        end
      else
        if @user.update_without_password(user_params)
          redirect_to users_path, notice:"User information was successfully updated!"
        else
          render :edit
        end
      end
    end
  rescue StandardError => e
    redirect_to edit_user_path(@user), alert: 'Failed to update User. An error occurred while processing your request.'
    Rails.logger.error("Error occurred while updating user: #{e.message}")
    raise ActiveRecord::Rollback # Rollback the transaction
  end

  # Deletes an existing user
  def destroy
    ActiveRecord::Base.transaction do
      @user = User.find(params[:id])
      Notification.where(actor_id: @user.id).destroy_all
      if @user.destroy
        redirect_to users_path, notice: 'Account has been successfully deleted.'
      else
        flash[:alert] = 'Unable to delete the account. Please try again.'
        redirect_to user_path(@user)
      end
    end
  rescue StandardError => e
    redirect_to users_path, alert: 'Failed to delete User. An error occurred while processing your request.'
    Rails.logger.error("Error occurred while deleting user: #{e.message}")
    raise ActiveRecord::Rollback # Rollback the transaction
  end

  # Serach for users based on users' name
  def search
    if params[:search].blank?
      redirect_to users_path, alert: "Type User Name to search"
    else
      @parameter = params[:search].downcase
      @results = User.search_by_name(@parameter)
    end
  end

  # Import users from speradsheet
  def import
    if params[:file].present?
      if params[:file].original_filename.split('.').last.downcase != 'xls'
        redirect_to users_path, alert: "Invalid File Format"
        return
      end
      begin
        spreadsheet = Spreadsheet.open(params[:file].tempfile)
        sheet = spreadsheet.worksheet(0)

        successful_imports = 0
        existing_users = []

        sheet.each_with_index do |row, index|
          next if index == 0
          user_params = {
            name: row[0],
            email: row[1]
          }
          # Generate a random password
          generated_password = SecureRandom.hex(8)
          user_params[:password] = generated_password
          user_params[:password_confirmation] = generated_password

          user = User.new(user_params)

          if user.save
            successful_imports += 1
          else
            # If user already exists, log the email and skip
            if user.errors[:email].include?("has already been taken")
              existing_users << user_params[:email]
            else
              Rails.logger.error "Error importing user: #{user.errors.full_messages.join(', ')}"
            end
          end
        end
        # Notice message based on the import result
        if successful_imports > 0
          notice = "Successfully imported #{successful_imports} users"
          notice += ". The following users already exist: #{existing_users.join(', ')}" unless existing_users.empty?
          redirect_to users_path, notice: notice
        # If no successful imports occurred
        else
          redirect_to users_path, alert: "Failed to import any users"
        end
      rescue Ole::Storage::FormatError => e
        Rails.logger.error "OLE2 signature is invalid: #{e.message}"
        redirect_to users_path, alert: "Invalid File Format"
      end
    else
      redirect_to users_path, alert: "No file selected for import."
    end
  end

  # Export users to spreasheet
  def export
    @users = User.all
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'Users'
    sheet1.row(0).concat %w{Name Email Created_at Updated_at Admin}
    @users.each_with_index do |user, index|
      sheet1.row(index + 1).replace [user.name, user.email, user.created_at, user.updated_at, user.admin]
    end
    blob = StringIO.new
    book.write blob
    blob.rewind
    send_data blob.read, filename: "users.xls", type: "application/vnd.ms-excel"
  end

  # Delete user's image
  def delete_image
    ActiveRecord::Base.transaction do
      @user = User.find(params[:id])
      @user.image.purge if @user.image.attached?
      redirect_to edit_user_registration_path, notice: 'Image deleted successfully.'
  end
  rescue StandardError => e
    redirect_to edit_user_registration_path, alert: 'Failed to delete user image. An error occurred while processing your request.'
    Rails.logger.error("Error occurred while deleting user image: #{e.message}")
    raise ActiveRecord::Rollback # Rollback the transaction
  end

  # Method to save movie
  def saved_movies
    @user = current_user
    @saved_movies = @user.movies.page(params[:page]).per(24)
    current_user.activities.create(action:"Browsed Saved Movies Page")
  end

  # unsave the movie
  def unsave
    @movie = Movie.find(params[:id])
    saved_movie = current_user.saved_movies.find_by(movie_id: @movie.id)

    if saved_movie
      saved_movie.destroy
      redirect_to (request.referrer || root_path), notice: 'Movie was removed from saved list successfully.'
    else
      redirect_to @movie, notice: 'Movie is not in saved list'
    end
  end


#  # Method to change role of user
#  def toggle_admin
#    @user = User.find(params[:id])
#
#    # Toggle the admin attribute based on the selected value from the form
#    @user.admin = params[:admin] == "true"
#
#    if @user.save
#      redirect_back fallback_location: users_path, notice: "User role updated successfully."
#    else
#      redirect_back fallback_location: users_path, alert: "Failed to update user role."
#    end
#  end

  # Method for admin's dashboard
  def dashboard
    @users = User.where.not(admin: 1) # Exclude admin users
    @activities = Activity.joins(:user).where(users: { admin: 0 }).order(created_at: :desc).page(params[:page]).per(10)
  end

  # Method for filtering activites based on user
  def filter_by_user
    if params[:user_id].present? && params[:user_id] != ""
      @user = User.find(params[:user_id])
      @activities = @user.activities.order(created_at: :desc).page(params[:page]).per(10)
    else
      @users = User.where.not(admin: 1) # Exclude admin users
      @activities = Activity.joins(:user).where(users: { admin: 0 }).order(created_at: :desc).page(params[:page]).per(10)
    end
  end
  

  # Method for filtering activites based on time
  def filter_by_time
    @users = User.where.not(admin: true) # Exclude admin users

    case params[:time_period]
    
    when "All"
      @period = "All time"
      @users = User.where.not(admin: 1) # Exclude admin users
      @activities = Activity.joins(:user).where(users: { admin: 0 }).order(created_at: :desc).page(params[:page]).per(10)
    when "Today"
      @period = "Today"
      @activities = Activity.where("created_at >= ?", Time.zone.now.in_time_zone("Asia/Yangon").beginning_of_day).where(user_id: @users.pluck(:id)).order(created_at: :desc).page(params[:page]).per(10)
    when "This Week"
      @period = "This Week"
      @activities = Activity.where("created_at >= ?", Time.zone.now.in_time_zone("Asia/Yangon").beginning_of_week).where(user_id: @users.pluck(:id)).order(created_at: :desc).page(params[:page]).per(10)
    when "This Month"
      @period = "This Month"
      @activities = Activity.where("created_at >= ?", Time.zone.now.in_time_zone("Asia/Yangon").beginning_of_month).where(user_id: @users.pluck(:id)).order(created_at: :desc).page(params[:page]).per(10)
    end
  end

  private

  # Method checking if current_user is admin
  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  private
  # Defines the permitted parameters for a user
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation,:admin,:image)
  end

  # Sets the feedback instance variable
  def set_feedback
    @feedback = Feedback.new
  end

  # Method checking if current_user is admin
  def check_admin
    redirect_to root_path, alert: 'You do not have access to this page' unless current_user && current_user.admin?
  end

end
