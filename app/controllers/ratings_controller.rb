# app/controllers/ratings_controller.rb
# frozen_string_literal: true

# This controller manages ratings related to movies.
class RatingsController < ApplicationController
  # Only registered user can access rating feature
  before_action :authenticate_user!

  # Method to create rating
  def create
    @movie = Movie.find(params[:movie_id])

    # Check if the user has already rated the movie
    existing_rating = @movie.ratings.find_by(user: current_user)
    if existing_rating
      if existing_rating.update(rating_params)
        redirect_to @movie, notice: 'Your rating has been updated.'
      else
        redirect_to @movie, alert: 'Failed to update your rating.'
      end
    else
      @rating = @movie.ratings.build(rating_params)
      @rating.user = current_user
      if @rating.save
        redirect_to @movie, notice: 'Rating Added!'
      else
        redirect_to @movie, alert: 'Rating could not be added!'
      end
    end
  end
  def destroy
    @rating = Rating.find(params[:id])
    @movie = @rating.movie

    if @rating.destroy
      redirect_to @movie, notice: 'Rating has been successfully removed.'
    else
      redirect_to @movie, alert: 'Failed to remove the rating.'
    end
  end


  private

  def rating_params
    params.require(:rating).permit(:rating)
  end
end
