# app/controllers/years_controller.rb
# frozen_string_literal: true

# This controller manages year-related actions such as create, read, update and delete.
class YearsController < ApplicationController
  before_action :set_feedback
  #before_action :authenticate_user!
  before_action :check_admin, only: [:new, :edit]
  require 'spreadsheet'

  # Displays a paginated list of year
  def index
    @years = Year.order(year: :desc).page(params[:page]).per(10)
  end

  # Show movies related to year
  def show
    @years = Year.order(year: :desc).all
    @genres = Genre.order(:name).all
    @year = Year.find(params[:id])
    @result = Movie.released_in_year(@year.year).page(params[:page]).per(24)
    if current_user
      current_user.activities.create(action: "Filtered movies with year '#{@year.year}'")
    end
  end

  # Renders the form of creating new year
  def new
    @year = Year.new
  end

  # Creates new year
  def create
    ActiveRecord::Base.transaction do
      @year = Year.new(year_params)
      if @year.save
        redirect_to years_path, notice: "Released Year was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue StandardError => e
     # Rollback the transaction
     redirect_to years_path, alert: "Error occurred: #{e.message}"
    raise ActiveRecord::Rollback
    #redirect_to years_path, alert: "Error occurred: #{e.message}"
  end

  # Renders the form for editing an existing year
  def edit
    @year = Year.find(params[:id])
  end

  # Updates the existing year
  def update
    ActiveRecord::Base.transaction do
      @year = Year.find(params[:id])
      if @year.update(year_params)
        redirect_to years_path, notice: "Released Year was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  rescue StandardError => e
    redirect_to years_path, alert: "Error occurred: #{e.message}"
    raise ActiveRecord::Rollback # Rollback the transaction
    #redirect_to years_path, alert: "Error occurred: #{e.message}"
  end

  # Deletes an existing year
  def destroy
    ActiveRecord::Base.transaction do
      @year = Year.find_by(id: params[:id])
      if @year
        @year.destroy!
        redirect_to years_path, notice: "Released Year was successfully destroyed."
      else
        redirect_to years_path, alert: "Year not found."
      end
    end
  rescue StandardError => e
    redirect_to years_path, alert: "Error occurred: #{e.message}"
    raise ActiveRecord::Rollback # Rollback the transaction
  end

  # Serach related years based on search input
  def search
    if params[:search].blank?
      redirect_to years_path, alert: "Type Year to search"
    else
      @parameter = params[:search]
      @results = Year.search_by_year(@parameter)
    end
  end

  # Import years from spreadsheet
  def import
    if params[:file].present?
      if params[:file].original_filename.split('.').last.downcase != 'xls'
        redirect_to years_path, alert: "Invalid File Format"
        return
      end
      begin
        spreadsheet = Spreadsheet.open(params[:file].tempfile)
        sheet = spreadsheet.worksheet(0)

        successful_imports = 0
        existing_years = []
        invalid_years = []

        sheet.each_with_index do |row, index|
          # Skip the header row
          next if index == 0

          # Extract data from the current row
          year_value = row[1].to_i
          unless /^\d{4}$/ === year_value.to_s
            invalid_years << year_value
            next
          end
          # Check if the year already exists
          if Year.exists?(year: year_value)
            existing_years << year_value
          else
            # Create a new Year record
            year = Year.new(year: year_value)
            if year.save
              successful_imports += 1
            else
              Rails.logger.error "Error importing year: #{year.errors.full_messages.join(', ')}"
            end
          end
        end

        # Notice message based on the import result
        if successful_imports > 0
          notice = "Successfully imported #{successful_imports} years"
          notice += ". The following years already exist: #{existing_years.join(', ')}" unless existing_years.empty?
          redirect_to years_path, notice: notice
        # If no successful imports occurred
        else
          redirect_to years_path, alert: "Failed to import any years"
        end
      rescue Ole::Storage::FormatError => e
        Rails.logger.error "OLE2 signature is invalid: #{e.message}"
        redirect_to years_path, alert: "Invalid File Format"
      end
    else
      redirect_to years_path, alert: "No file selected for import."
    end
  end

  # Export yeats to spreadsheet
  def export
    @years = Year.all
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'Released Years'
    sheet1.row(0).concat %w{No Year}
    @years.each_with_index do |year, index|
      movies_list = Movie.released_in_year(year.year).pluck(:name).join(", ")
      sheet1.row(index + 1).replace [index+1,year.year,movies_list]
    end
    blob = StringIO.new
    book.write blob
    blob.rewind
    send_data blob.read, filename: "released_years.xls", type: "application/vnd.ms-excel"
  end
  # Save the movies of user's choice
  def save
    @movie = Movie.find(params[:id])
    current_user.movies << @movie unless current_user.movies.include?(@movie)
    redirect_to request.referrer, notice: "Movie saved successfully."
  end

  # POST /movies/:id/unsave
  def unsave
    @movie = Movie.find(params[:id])
    saved_movie = current_user.saved_movies.find_by(movie_id: @movie.id)

    if saved_movie
      saved_movie.destroy
      redirect_to request.referrer, notice: 'Movie was removed from saved list successfully.'
    else
      redirect_to @movie, notice: 'Movie is not in saved list'
    end
  end
  private
  # Defines the premitted parameter for year
  def year_params
    params.require(:year).permit(:year)
  end

  # Sets the feedback instance variable
  def set_feedback
    @feedback = Feedback.new
  end

  def check_admin
    redirect_to root_path, alert: 'You do not have access to this page' unless current_user && current_user.admin?
  end
end
