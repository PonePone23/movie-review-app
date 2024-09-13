# app/controllers/movies_controller.rb
# frozen_string_literal: true

# This controller manages saved movies of user
class SavedMoviesController < ApplicationController
  # Only registered user can accees saved_movies features
  before_action :authenticate_user!

  # Add saved movies to the saved movies list related to current user
  def create
    @movie = Movie.find_by(id: params[:id])

    if @movie
      current_user.saved_movies.create(movie: @movie)
      redirect_to movie_path(@movie), notice: 'Movie saved successfully.'
    else
      redirect_to root_path, alert: 'Movie not found.'
    end

  end

  # Index page for showing saved movies lists of current user
  def index
    @saved_movies = current_user.saved_movies.map(&:movie)
  end
end
