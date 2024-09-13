# app/controllers/genres_controller.rb
# frozen_string_literal: true

# This controller manages genres related to movies.
class GenresController < ApplicationController
  before_action :set_feedback
  before_action :authenticate_user!
  before_action :check_admin, only: [:new, :edit]
  require 'spreadsheet'

  # Displays a paginated list of genres.
  def index
    @genres = Genre.order(:name).page(params[:page]).per(10)
  end

  ## Shows movies associated with a specific genre.
  #def show
  #  @genre = Genre.find_by(params[:id])
  #  if @genre.nil?
  #    flash[:error] = "Genre not found."
  #    redirect_to genres_path # Redirect to the genres index page or any other appropriate action
  #  else
  #    @movies = @genre.movies
  #  end
  #end

  # Renders the form for creating a new genre.
  def new
    @genre = Genre.new
  end

  # Creates a new genre.
  def create
    ActiveRecord::Base.transaction do
      @genre = Genre.new(genre_params)
      respond_to do |format|
        if @genre.save
          format.html { redirect_to genres_path, notice: "Genre was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @genre.errors, status: :unprocessable_entity }
        end
      end
    end
  rescue StandardError => e
    redirect_to new_genre_path, alert: "Error occurred: #{e.message}"
    raise ActiveRecord::Rollback # Rollback the transaction
    #redirect_to new_genre_path, alert: "Error occurred: #{e.message}"
  end

  # Renders the form for editing an existing genre.
  def edit
    @genre = Genre.find(params[:id])
  end

  # Updates an existing genre.
  def update
    ActiveRecord::Base.transaction do
      @genre = Genre.find(params[:id])
      if @genre.update(genre_params)
        redirect_to genres_path, notice: "Genre was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  rescue StandardError => e
    redirect_to edit_genre_path, alert: "Error occurred: #{e.message}"
    raise ActiveRecord::Rollback # Rollback the transaction
    #redirect_to edit_genre_path, alert: "Error occurred: #{e.message}"
  end

  # Deletes the existing genre.
  def destroy
    ActiveRecord::Base.transaction do
      @genre = Genre.find_by(id: params[:id])
      if @genre
        @genre.destroy!
        redirect_to genres_path, notice: "Genre was successfully destroyed."
      else
        redirect_to genres_path, alert: "Genre not found."
      end
    end
  rescue StandardError => e
    redirect_to genres_path, alert: "Failed to delete Genre. An error occurred while processing your request."
    raise ActiveRecord::Rollback # Rollback the transaction
    #redirect_to genres_path, alert: 'Failed to delete Movie. An error occurred while processing your request.'
  end

  # Searches for genres based on user input
  def search
    if params[:search].blank?
      redirect_to genres_path, alert: "Type Genre Name to search"
    else
      @parameter = params[:search].downcase
      @results = Genre.search_by_name(@parameter)
    end
  end

  # Imports genres from a spreadsheet.
  def import
    ActiveRecord::Base.transaction do
      if params[:file].present?
        if params[:file].original_filename.split('.').last.downcase != 'xls'
          redirect_to genres_path, alert: "Invalid File Format"
          return
        end
        successful_imports = 0
        existing_genres = []
        begin
          book = Spreadsheet.open(params[:file].tempfile)
          sheet = book.worksheet(0)
          if sheet.nil?
            Rails.logger.error "No worksheet found in the spreadsheet."
            redirect_to genres_path, alert: "No worksheet found in the spreadsheet."
            return
          end
          sheet.each_with_index do |row, index|
            next if index == 0
            name = row[1] # Adjust index to skip the first column
            if name.present? && name.is_a?(Numeric)
              Rails.logger.error "Invalid data format: #{name} is numeric. Skipping import for this row."
              next
            end
            if Genre.exists?(name: name)
              existing_genres << name
            else
              genre = Genre.new(name: name)
              if genre.save
                successful_imports += 1
              else
                Rails.logger.error "Error importing genre: #{genre.errors.full_messages.join(', ')}"
              end
            end
          end
          # Notice message based on the import result
          if successful_imports > 0
              notice = "Successfully imported #{successful_imports} genres"
              notice += ". The following genres already exist: #{existing_genres.join(', ')}" unless existing_genres.empty?
              redirect_to genres_path, notice: notice
            # If no successful imports occurred
          else
              redirect_to genres_path, alert: "Failed to import any genres"
          end
        rescue Ole::Storage::FormatError => e
          Rails.logger.error "OLE2 signature is invalid: #{e.message}"
          redirect_to genres_path, alert: "Invalid File Format"
        end
      else
        redirect_to genres_path, alert: "No file selected for import."
      end
    end
  end

  # Exports genres to a spreadsheet.
  def export
    ActiveRecord::Base.transaction do
      @genres = Genre.all
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet :name => 'Released Years'
      sheet1.row(0).concat %w{No Genre Movies}
      @genres.each_with_index do |genre, index|
        movies_names = genre.movies.pluck(:name).join(', ')
        sheet1.row(index + 1).replace [index+1,genre.name,movies_names]
      end
      blob = StringIO.new
      book.write blob
      blob.rewind
      send_data blob.read, filename: "genres.xls", type: "application/vnd.ms-excel"
    end
  end

  private

  # Defines the permitted parameters for a genre.
  def genre_params
    params.require(:genre).permit(:name)
  end

  def set_genre
    @genre = Genre.find(params[:id])
  end

  # Sets the feedback instance variable
  def set_feedback
    @feedback = Feedback.new
  end

  def check_admin
    redirect_to root_path, alert: 'You do not have access to this page' unless current_user && current_user.admin?
  end
end
