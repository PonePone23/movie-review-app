# app/controllers/comments_controller.rb
# frozen_string_literal: true

# This controller manages comments related to movies.
class CommentsController < ApplicationController
  include Turbo::Streams
  before_action :find_movie_and_user
  helper_method :admin_user_id

  # Creates a new comment for a movie.
  def create
    ActiveRecord::Base.transaction do
      @comment = @movie.comments.new(comment_params)
      @comment.user = @user

      if @comment.user.admin?
        @comment.status = true
      end

      if @comment.save
        if @comment.user.admin?
          redirect_to movie_path(@movie), notice: 'Review was successfully created.'
        else
          admins = User.where(admin: true)
          admins.each do |admin|
            Notification.create(recipient: admin, actor: @comment.user, action: 'created_review', notifiable: @comment)
          end
          if current_user
            current_user.activities.create(action:"Added review in '#{@movie.name}'")
          end
          redirect_to movie_path(@movie), notice: 'Your Review is pending. Admin will approve it soon.'
        end
      else
        @error_message = 'Review cannot be blank and must be at least 100 characters and at most 600 characters.'
        render turbo_stream: turbo_stream.replace('comment_form', partial: 'comments/form', locals: { movie: @movie, user: @user, error_message: @error_message })
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error occurred while creating comment: #{e.message}")
    redirect_to movie_path(@movie), alert: 'Failed to create Review. An error occurred while processing your request.'
    raise ActiveRecord::Rollback # Rollback the transaction
  end

  def destroy
      @comment = @movie.comments.find(params[:id])
      if @comment.destroy
        Notification.create(recipient: @comment.user, actor: current_user, action: 'deleted_comment', notifiable: @comment)
        redirect_to movie_path(@movie), notice: 'Review was successfully deleted.'
        if current_user
          current_user.activities.create(action:"Deleted review in '#{@movie.name}'")
        end
      else
        redirect_to movie_path(@movie), alert: 'Error deleting review.'
      end
  end

  # Approves a comment.
  def approve
    @comment = Comment.find(params[:id])

    if @comment.update(status: true)
      # Check if the comment was created by a normal user
      if !@comment.user.admin?
        # Find the corresponding notification and delete it
        notification = Notification.find_by(notifiable: @comment)
        notification.destroy if notification
      end
      Notification.create(recipient: @comment.user, actor: current_user, action: 'approved_comment', notifiable: @comment)
      redirect_to movie_path(@movie, @user), notice: 'Review approved successfully.'
    else
      redirect_to movie_path(@movie, @user), notice: 'Review could not be updated.'
    end
  end

  private
  # Finds the movie and user associated with the comment.
  def find_movie_and_user
    @movie = Movie.find(params[:movie_id])
    @user = User.find(params[:user_id])
  end

  # Defines the permitted parameters for a comment.
  def comment_params
    params.require(:comment).permit(:description, :status)
  end

   # Method to get the ID of the admin user
   def admin_user_id
    # Your logic to fetch the ID of the admin user
    # This could be based on a role or any other criteria specific to your application
    # For demonstration purposes, I'll assume you have a 'role' attribute on the User model
    admin_user = User.find_by(admin: 1)
    admin_user.id if admin_user
  end
end
