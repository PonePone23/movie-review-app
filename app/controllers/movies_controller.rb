# app/controllers/movies_controller.rb
# frozen_string_literal: true

# This controller manages movies and related actions.
class MoviesController < ApplicationController
  before_action :set_feedback
  before_action :check_admin, only: :new
  before_action :set_movie, only: [:show, :edit, :update, :destroy, :save]

  # Displays a paginated list of movies.
  def index
    @movies = Movie.order(updated_at: :desc).page(params[:page]).per(12
    )
    @genres = Genre.order(:name).all
    @years = Year.order(year: :desc).all
    @movies_by_rating = Movie.joins(:ratings).group('movies.id').order('AVG(ratings.rating) DESC')
    @upcoming_movies = Movie.where("release_date > ?", Date.today)
    @history_entries = current_user.histories.includes(:movie) if current_user
  end

  # Shows details of a specific movie.
  def show
    @movie = Movie.find_by(id: params[:id])
    if current_user
      current_user.activities.create(action: "Viewed movie #{@movie.name}")
      existing_history = current_user.histories.find_by(movie_id: @movie.id)

      unless existing_history
        history = current_user.histories.create(movie: @movie)
      end
    end
    @movies = Movie.all
    @genres = Genre.all
    @ratings = @movie.rating

    if current_user && current_user.admin?
      @comments = @movie.comments.order(created_at: :desc).page(params[:page]).per(5)
    else
      visible_comments = @movie.comments.where(status: true)
      @comments = visible_comments.order(created_at: :desc).page(params[:page]).per(5)
    end
  end

  # Renders the form for creating a new movie.
  def new
    @movie = Movie.new
    @genres = Genre.all
  end

  # Creates a new movie.
  def create
    ActiveRecord::Base.transaction do
      @movie = Movie.new(movie_params)
      @movie.user_id = current_user.id
      @genres = Genre.all
      genre_ids = params[:movie][:genre_ids]
      if genre_ids.present?
        @movie.genre_ids = genre_ids
      end
      respond_to do |format|
        if @movie.save
          format.html { redirect_to movie_url(@movie), notice: "Movie was successfully created." }
          format.json { render :show, status: :created, location: @movie }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @movie.errors, status: :unprocessable_entity }
        end
      end
    end
  rescue StandardError => e
    redirect_to new_movie_path, alert: 'Failed to create Movie. An error occurred while processing your request.'
    Rails.logger.error("Error occurred while creating movie: #{e.message}")
    raise ActiveRecord::Rollback # Rollback the transaction
  end

  # Renders the form for editing an existing movie.
  def edit
    @movie = Movie.find_by(id: params[:id])
    @genres = Genre.all
  end

  # Updates an existing movie.
  def update
    ActiveRecord::Base.transaction do
      @movie = Movie.find_by(id: params[:id])

      respond_to do |format|
        if @movie.update(movie_params)
          if params[:movie][:genre_ids].present?
            @movie.genre_ids = params[:movie][:genre_ids]
          else
            # If no genres are selected, clear existing associations
            @movie.genre_ids = []
          end
          format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
          format.json { render :show, status: :ok, location: @movie }
        else
          @genres = Genre.all  # Reassign @genres for the form
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @movie.errors, status: :unprocessable_entity }
        end
      end
    end
  rescue StandardError => e
    redirect_to edit_movie_path(@movie), alert: 'Failed to update Movie. An error occurred while processing your request.'
    Rails.logger.error("Error occurred while updating movie: #{e.message}")
    raise ActiveRecord::Rollback # Rollback the transaction
  end

  # Deletes an existing movie.
  def destroy
    @movie = Movie.find_by(id: params[:id])
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Displays movies belonging to a specific genre.
  def by_genre
    @index = 0
    @genres = Genre.order(:name).all
    @years = Year.order(year: :desc).all
    @genre = Genre.find_by(id: params[:genre_id])
    if @genre.nil?
      flash[:error] = "Genre not found."
      redirect_to root_path
    else
      @movies = @genre.movies.page(params[:page]).per(24)
      if current_user
        current_user.activities.create(action: "Filtered movies with genre '#{@genre.name}'")
      end
    end
  end

  # Searches for movies based on user input.
  def search
    if params[:search].blank?
      redirect_to root_path, alert: "Type movie name or casts, or director or country to search"
    else
      @parameter = params[:search].downcase
      @results = Movie.search_by_keyword(@parameter)
      if current_user
        current_user.activities.create(action:"Search for movies with keyword #{@parameter}")
      end
    end
  end

  # Save the movies of user's choice
  def save
    @movie = Movie.find(params[:id])
    current_user.movies << @movie unless current_user.movies.include?(@movie)
    redirect_to request.referrer, notice: "Movie saved successfully.", allow_other_host: true
    current_user.activities.create(action:"Save '#{@movie.name}' into Saved Moives List.")
  end

  # POST /movies/:id/unsave
  def unsave
    @movie = Movie.find(params[:id])
    saved_movie = current_user.saved_movies.find_by(movie_id: @movie.id)

    if saved_movie
      saved_movie.destroy
      current_user.activities.create(action:"Unsave '#{@movie.name}' from Saved Movies List.")
      redirect_to request.referrer, notice: 'Movie was removed from saved list successfully.', allow_other_host: true
    else
      redirect_to @movie, notice: 'Movie is not in saved list'
    end
  end

  #set up_coming movie releases
  def up_coming
    if current_user
      current_user.activities.create(action: 'Browsed UpComing Movies page')
    end
    #@movies_by_rating = Movie.joins(:ratings).group('movies.id').order('AVG(ratings.rating) DESC')
    @upcoming_movies = Movie.where("release_date > ?", Date.today)
  end

  def find_cast_relate_movie
    @cast = params[:cast]
    @id = params[:movie_id]
    excluded_movie_id = @id
    @cast_movies = Movie.where("casts LIKE ? AND id != ?", "%#{@cast}%", excluded_movie_id).page(params[:page]).per(24)
    render 'cast_movie'
  end

  def find_director_relate_movie
    @director = params[:director]
    @id = params[:movie_id]
    excluded_movie_id = @id
    @director_movies = Movie.where("director LIKE ? AND id != ?", "%#{@director}%", excluded_movie_id).page(params[:page]).per(24)
    render 'director_movie'
  end

  private

  # Sets the movie instance variable.
  def set_movie
    @movie = Movie.find(params[:id])
  end

  # Defines the permitted parameters for a movie.
  def movie_params
    params.require(:movie).permit(:name, :review, :casts, :release_date, :country, :production, :director, :duration, :trailer_url, :user_id, :rating, :image, genre_ids: [])
  end

  # Sets the feedback instance variable.
  def set_feedback
    @feedback = Feedback.new
  end

  def check_admin
    redirect_to root_path, alert: 'You do not have access to this page' unless current_user && current_user.admin?
  end

end
