# spec/requests/movie_spec.rb
require 'rails_helper'

RSpec.describe MoviesController, type: :controller do
  include Devise::Test::ControllerHelpers
  after(:each) do
    Movie.destroy_all
    Genre.destroy_all
    User.destroy_all
    # Add cleanup for other relevant models if needed
  end

  # Test cases for index action
  describe "GET #index" do
    # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    let(:comment1) { Comment.create(description: "This is comment1.", status: 1, movie: movie, user: user) }
    let(:comment2) { Comment.create(description: "This is comment2.", status: 0, movie: movie, user: user) }
    # Create 30 movies for the test
    before do
      30.times do |i|
        movie = Movie.create(
          name: "Sample Movie #{i + 1}",
          review: 'This is a review of the movie.',
          release_date: Date.today,
          duration: '1h 22m',
          trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
          user: user,
          genre_ids: [genre.id], # Use genre.id instead of genre1.id and genre2.id
          image: fixture_file_upload('m01.png', 'image/png')
        )
      end
    end

    # Expect to return the index page successfully
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    # Test pagination functionality and expect to return 24 movies per page
    it 'returns a successful response and loads the first page of movies' do
      get :index, params: { page: 1, per_page: 24 }
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expected_movies = Movie.order(updated_at: :desc).page(1).per(24)
      assigned_movies = assigns(:movies)
      expected_movies.each_with_index do |movie, index|
        expect(assigned_movies[index].name).to eq(movie.name)
      end
    end

    # Expect to return another 24 movies at second page of pagination
    it 'returns the specified page of movies' do
      get :index, params: { page: 2, per_page: 24 }
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      assigned_movies = assigns(:movies)
      expect(assigned_movies).not_to be_nil
      if assigned_movies.present?
        expect(assigned_movies[0].name).to eq("Sample Movie 6")
      else
        expect(assigned_movies).to eq([])
      end
    end

    # Test assignments of @genres and @years variables
    it "assigns @movies, @genres, and @years" do
      get :index
      expect(assigns(:movies)).to eq(Movie.order(updated_at: :desc).page(1).per(24))
      expect(assigns(:genres)).to eq(Genre.order(:name).all)
      expect(assigns(:years)).to eq(Year.order(year: :desc).all)
    end
  end

  # Test for show action
  describe "GET #show" do
    # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    let(:comment1) { Comment.create(description: "This is comment1.", status: 1, movie: movie, user: user) }
    let(:comment2) { Comment.create(description: "This is comment2.", status: 0, movie: movie, user: user) }

    # Expect to return the show page successfully
    it 'returns a successful response' do
      get :show, params: { id: movie.id }
      expect(response).to be_successful
    end

    # Expect to show the requested movie correctly
    it 'assigns the requested movie' do
      get :show, params: { id: movie.id }
      expect(assigns(:movie)).to eq(movie)
    end

    # Expect to give the show template successfully
    it 'renders the show template' do
      get :show, params: { id: movie.id }
      expect(response).to render_template('show')
    end

    # Testing visibility of comments for admin users
    context "when user is an admin" do
      #Set up initial data for user and sign_in as admin
      before do
        sign_in(user)
        user.update(admin:1)
        get :show, params: { id: movie.id }
      end

      it "assigns @movie" do
        expect(assigns(:movie)).to eq(movie)
      end

      # Expect to show all comments
      it "assigns @comments to all comments" do
        expect(assigns(:comments)).to include(comment1, comment2)
      end

      # Expect to render the show template
      it "renders the show template" do
        expect(response).to render_template("show")
      end
    end

    # Test visibility of comments when user is not admin
    context "when user is not an admin" do
      # Set up initial data for user and sign_in as not admin
      before do
        sign_in(user)
        get :show, params: { id: movie.id }
      end

      it "assigns @movie" do
        expect(assigns(:movie)).to eq(movie)
      end

      # Expect to show only the comments where status is 1
      it "assigns @comments to only visible comments" do
        expect(assigns(:comments)).to include(comment1)
      end

      # Expect to render the show template
      it "renders the show template" do
        expect(response).to render_template("show")
      end
    end
  end

  # Test cases for new action
  describe "GET #new" do
      # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    # Expect to return new movie page successfully
    it "returns a success response" do
      sign_in user
      get :new
      expect(response).to be_successful
    end

    # Expect new movie to be assign
    it 'assigns a new movie to @movie' do
      sign_in user
      get :new
      expect(assigns(:movie)).to be_a_new(Movie)
      expect(assigns(:genres)).to eq(Genre.all)
    end
  end

  # Test cases for edit action
  describe 'GET #edit' do
    # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    # Expect to return the edit page successfully
    it 'returns a successful response' do
      sign_in user
      get :edit, params: { id: movie.id }
      expect(response).to be_successful
    end

    # Expect edited_movie to be assign
    it 'assigns the requested movie to @movie' do
      sign_in user
      get :edit, params: { id: movie.id }
      expect(assigns(:movie)).to eq(movie)
      expect(assigns(:genres)).to eq(Genre.all)
    end
  end

  # Test cases for create action
  describe 'POST #create' do
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    # Test cases for valid parameters for movie
    context 'with valid parameters' do
      # Expect movie to be valid with valid parameters
      it 'creates a new movie' do
        sign_in user
        genre1 = Genre.create(name: 'Action')
        genre2 = Genre.create(name: 'Comedy')
        movie_params = {
          name: 'Sample Movie',
          review: 'This is a review of movie.',
          release_date: Date.today,
          duration: '1h 22m',
          trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
          user: user,
          genre_ids: [genre1.id, genre2.id],
          image: fixture_file_upload('m01.png', 'image/png')
        }
        expect {
          post :create, params: { movie: movie_params }
        }.to change(Movie, :count).by(1)
      end
    end

    # Test cases with invalid parameters
    context 'with invalid parameters' do
      # Expect movie not to be created with invalid paramenters
      it 'does not create a new movie' do
        sign_in user
        invalid_params = {name: 'Movie'}
        expect {
          post :create, params: { movie: invalid_params }
        }.not_to change(Movie, :count)
      end

      # Expect to redirect to new page with invalid parameter
      it 'renders the new template' do
        sign_in user
        invalid_params = {name: 'movie'}
        post :create, params: { movie: invalid_params }
        expect(response).to render_template(:new)
      end
    end

    context 'when an error occurs during movie creation' do
      # Expect to raise ActiveRecord error when error occurs during movie creation
      it 'logs the error and redirects with alert' do
        sign_in user
        genre1 = Genre.create(name: 'Action')
        genre2 = Genre.create(name: 'Comedy')
        movie_params = {
          name: 'Sample Movie',
          review: 'This is a review of movie.',
          release_date: Date.today,
          duration: '1h 22m',
          trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
          user: user,
          genre_ids: [genre1.id, genre2.id],
          image: fixture_file_upload('m01.png', 'image/png')
        }
        expect(Rails.logger).to receive(:error).with(/Error occurred while creating movie/)
        allow(Movie).to receive(:new).and_raise(StandardError, 'Test error message')
        expect{
          post :create, params: movie_params
        }.to raise_error(ActiveRecord::Rollback)
        expect(response).to redirect_to(new_movie_path)
        expect(flash[:alert]).to eq('Failed to create Movie. An error occurred while processing your request.')
      end
    end
  end

  # Test cases for update action
  describe 'PATCH #update' do
    # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    # Test cases with valid parameters
    context 'with valid parameters' do
      # Expect movie to be valid with valid parameter
      it "update the movie" do
        sign_in user
        new_name = "New movie name"
        patch :update, params: { id: movie.id, movie: { name: new_name } }
        movie.reload
        expect(movie.name).to eq(new_name)
      end

      # Expect movie to be able to update with new review
      it "update the movie review" do
        sign_in user
        new_review = "this is a new movie"
        patch :update, params: { id: movie.id, movie: { review: new_review } }
        movie.reload
        expect(movie.review).to eq(new_review)
      end

      # Expect to redirect to the updated movie
      it "redirects to the updated movie" do
        sign_in user
        new_name = "New movie name"
        patch :update, params: { id: movie.id, movie: { name: new_name } }
        expect(response).to redirect_to(movie)
      end

      # Expect not to update the genres
      it 'does not update the genres associated with the movie' do
        new_name = "New movie name"
        patch :update, params: { id: movie.id, movie: { name: new_name } }
        movie.reload
        expect(movie.genres.pluck(:id)).to eq(movie.genre_ids)
      end
    end

    # Test cases with invalid parameters
    context "with invalid params" do
      # Expect movie not to be able to update with invalid paramenters
      it "does not update the movie" do
        sign_in user
        patch :update, params: { id: movie.id, movie: { name: "" } }
        movie.reload
        expect(movie.name).to_not eq("")
      end

      # Expect to redirect to edit page with invalid movie parameter
      it 're-renders the edit template with status :unprocessable_entity' do
        sign_in user
        patch :update, params: { id: movie.id, movie: { name: '' } }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when an error occurs during movie updating' do
      # Expect to raise ActiveRecord error when an error occurs during movie updating
      it 'logs the error and redirects with alert' do
        sign_in user
        expect{
          post :update, params: { id: movie.id, user: { name: 'New name' } }
        }.to raise_error(ActiveRecord::Rollback)

        expect(response).to redirect_to(edit_movie_path(movie))
        expect(flash[:alert]).to eq('Failed to update Movie. An error occurred while processing your request.')
      end
    end
  end

  # Test cases for destroy action
  describe 'DELETE #destroy' do
    # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    # Expect movie to be destroyed and decrease count of total movies by 1
    it 'destroys the requested movie' do
      sign_in user
      delete :destroy, params: { id: movie.id }
      expect(Movie.exists?(movie.id)).to be_falsey
    end

    # Expect to redirect to list of movies after movie is destroyed
    it 'redirects to the movie list' do
      sign_in user
      delete :destroy, params: { id: movie.id }
      expect(response).to redirect_to(movies_url)
    end
  end

  # Test cases for search action
  describe 'GET #search' do
    # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    # Expect to redirect to root_path when search paramenter is blank
    it 'redirects to root_path if search parameter is blank' do
      get :search, params: { search: '' }
      expect(response).to redirect_to(root_path)
      expect(assigns(:parameter)).to be_nil
      expect(assigns(:results)).to be_nil
    end

    # Expect to create the activity for the current user
    it 'create activites for current user' do
      sign_in user
      get :search, params: { search: 'Sample Movie' }
      expect(user.activities.last.action).to eq("Search for movies with keyword sample movie")
    end

    # Expect to show result when search paramenter is present
    it 'assigns results if search parameter is present' do
      get :search, params: { search: 'Sample Movie' }
      expect(response).to have_http_status(:success)
      expect(assigns(:parameter)).to eq('sample movie')
      expect(assigns(:results)).to eq([movie])
      expect(response).to render_template(:search)
    end
  end

  describe "GET #by_genre" do
    # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin: 1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end

    # Test cases when genre exists
    context "when genre exists" do
      before do
        sign_in user
        get :by_genre, params: { genre_id: genre.id }
      end

      # Expect to assign the requested genre
      it "assigns the requested genre to @genre" do
        expect(assigns(:genre)).to eq(genre)
      end

      # Expect to assign the movies to related genre
      it "assigns movies of the genre to @movies" do
        expect(assigns(:movies)).to include(movie)
      end

      # Expect to render the by_genere template
      it "renders the :by_genre template" do
        expect(response).to render_template(:by_genre)
      end

      # Expect to create the activity
      it "creates activity for current user" do
        expect(user.activities.last.action).to eq("Filtered movies with genre '#{genre.name}'")
      end
    end

    # Test cases when genre do not exist
    context "when genre does not exist" do
      before do
        get :by_genre, params: { genre_id: genre.id + 1 } # Assuming non-existing id
      end

      # Expect to redirect to redirect to the root path
      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end

      # Expect to flash the error message
      it "sets flash error message" do
        expect(flash[:error]).to eq("Genre not found.")
      end
    end
  end

  # Test cases for save
  describe 'POST #save' do
    # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end

    before do
      sign_in user
    end

    # Test cases when movie is not saved
    context 'when movie is not already saved by the user' do
      # Expect to save the movie for current user
      it 'saves the movie to the user' do
        request.env['HTTP_REFERER'] = 'http://example.com'
        post :save, params: { id: movie.id }
        user.reload
        expect(user.movies).to include(movie)
      end

      # Expect to create the activity
      it 'creates a new activity for the user' do
        expect {
          request.env['HTTP_REFERER'] = 'http://example.com'
          post :save, params: { id: movie.id }
        }.to change(user.activities, :count).by(1)
      end

      # Expect to redirect to the referrer page with notice
      it 'redirects back with a notice' do
        request.env['HTTP_REFERER'] = 'http://example.com'
        post :save, params: { id: movie.id }
        expect(response).to redirect_to(request.referrer)
        expect(flash[:notice]).to eq('Movie saved successfully.')
      end
    end

    # Test cases whem movie is already saved
    context 'when movie is already saved by the user' do
      before do
        user.movies << movie
      end

      # Expect not to save the movie agian
      it 'does not save the movie again' do
        expect {
          request.env['HTTP_REFERER'] = 'http://example.com'
          post :save, params: { id: movie.id }
        }.not_to change(user.movies, :count)
      end
    end
  end

  # Test cases for unsave
  describe "POST #unsave" do
    # Initial data sett up
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin: 1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    # Test cases when movie is already saved
    context "when movie is saved by the user" do
      before do
        user.saved_movies.create(movie: movie) # Creating a SavedMovie record associated with the user and movie
        request.env['HTTP_REFERER'] = 'http://example.com'
        post :unsave, params: { id: movie.id }
      end

      # Expect to destroy the saved movie
      it "destroys the saved movie" do
        expect(user.saved_movies.find_by(movie_id: movie.id)).to be_nil
      end

      # Expect to create activity
      it "creates an activity for un-saving the movie" do
        expect(user.activities.last.action).to eq("Unsave '#{movie.name}' from Saved Movies List.")
      end

      # Expect to redirect back to referrer page with a notice
      it "redirects back to the referrer with a notice" do
        expect(response).to redirect_to(request.referrer)
        expect(flash[:notice]).to eq("Movie was removed from saved list successfully.")
      end
    end

    # Test cases when movie is not saved
    context "when movie is not saved by the user" do
      before do
        request.env['HTTP_REFERER'] = 'http://example.com'
        post :unsave, params: { id: movie.id }
      end

      # Expect to redirect to the movie with a notice
      it "redirects to the movie with a notice" do
        expect(response).to redirect_to(movie)
        expect(flash[:notice]).to eq("Movie is not in saved list")
      end
    end
  end

  # Test cases for up_coming page
  describe "GET #up_coming" do
    # Initial data setup
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin: 1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie1) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.tomorrow,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    let(:movie2) do
      Movie.create(
        name: 'Sample Movie 2',
        review: 'This is a review of the movie.',
        release_date: Date.tomorrow,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    # Expect to create activity
    it "creates activity when user browses the UpComing Movies page" do
      expect {
        get :up_coming
      }.to change { user.activities.count }.by(1)

      expect(user.activities.last.action).to eq('Browsed UpComing Movies page')
    end

    # Expect to fetches the upcoming movies
    it "fetches upcoming movies correctly" do
      get :up_coming
      expect(assigns(:upcoming_movies)).to match_array([movie1, movie2])
    end
  end

  # Test cases for finding the movies related to cast
  describe "GET #find_cast_relate_movie" do
    # Initial data set up
    let(:cast) { "Cast" }
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin: 1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
        Movie.create(
          name: 'Sample Movie',
          review: 'This is a review of the movie.',
          release_date: Date.today,
          duration: '1h 22m',
          trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
          user: user,
          genre_ids: [genre.id],
          casts: "Cast",
          image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    before do
      get :find_cast_relate_movie, params: { cast: cast, movie_id: movie.id }
    end

    # Expect to assign the cast
    it "assigns the cast" do
      expect(assigns(:cast)).to eq(cast)
    end

    # Expect to assign the movie ID
    it "assigns the movie ID" do
      expect(assigns(:id)).to eq(movie.id.to_s)
    end

    # Expect to fetch the movies related to the cast
    it "fetches related movies excluding the specified movie ID" do
      expect(assigns(:cast_movies)).not_to include(movie.id)
    end

    # Expect to render the cast_movie template
    it "renders the cast_movie template" do
      expect(response).to render_template("cast_movie")
    end
  end

  # Test cases for finding movies related to director
  describe "GET #find_director_relate_movie" do
    # Initial data setup
    let(:director) { "director" }
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin: 1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
        Movie.create(
          name: 'Sample Movie',
          review: 'This is a review of the movie.',
          release_date: Date.today,
          duration: '1h 22m',
          trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
          user: user,
          genre_ids: [genre.id],
          director: "director",
          image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    before do
      get :find_director_relate_movie, params: { director: director, movie_id: movie.id }
    end

    # Expect to assign the cast
    it "assigns the cast" do
      expect(assigns(:director)).to eq(director)
    end

    # Expect to assign the movie_ID
    it "assigns the movie ID" do
      expect(assigns(:id)).to eq(movie.id.to_s)
    end

    # Expect to fetches the movies related to director
    it "fetches related movies excluding the specified movie ID" do
      expect(assigns(:director_movies)).not_to include(movie.id)
    end

    # Expect to render the director_movie template
    it "renders the director_movie template" do
      expect(response).to render_template("director_movie")
    end
  end
end
