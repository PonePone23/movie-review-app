# spec/requests/saved_movies_controller_spec.rb
require 'rails_helper'

RSpec.describe SavedMoviesController, type: :controller do
  include Devise::Test::ControllerHelpers
  after(:each) do
    Movie.destroy_all
    Genre.destroy_all
    User.destroy_all
    # Add cleanup for other relevant models if needed
  end
  
  # Test cases for create action
  describe 'POST #create' do
    # Set up initial data for test Movie model
    let(:user){
      User.create(email:"admin@admin.com",password:"123123",admin:1,name:"admin")
    }
    let(:genre1) { Genre.create(name: 'Action') }
    let(:genre2) { Genre.create(name: 'Comedy') }
    let(:movie) do
      movie = Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end

    # Test cases when user is authenticated
    context 'when user is authenticated' do
      before { sign_in user }

      # Test cases with valid movie ID
      context 'with valid movie ID' do
        # Expect to create save movie for current user
        it 'creates a saved movie for the current user' do
          post :create, params: { id: movie.id }
          expect(user.saved_movies.last.movie).to eq(movie)
        end

        # Expect to redirect to the movie page when movie is successfully saved
        it 'redirects to the movie page with a success notice' do
          post :create, params: { id: movie.id }
          expect(response).to redirect_to(movie_path(movie))
          expect(flash[:notice]).to eq('Movie saved successfully.')
        end
      end

      # Test cases with invalid movie ID
      context 'with invalid movie ID' do
        # Expect to redirect to the root path with invalid movie ID
        it 'redirects to the root path with an alert' do
          post :create, params: { id: -1 }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('Movie not found.')
        end
      end
    end

    # Test cases when user is not authenticated
    context 'when user is not authenticated' do
      # Expect to redirect to the sign in page
      it 'redirects to the sign-in page' do
        post :create, params: { id: movie.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Test cases for index action
  describe 'GET #index' do
    # Initial data setup
        let(:user){
      User.create(email:"admin@admin.com",password:"123123",admin:1,name:"admin")
    }

    # Test cases when user is authenticated
    context 'when user is authenticated' do
      before { sign_in user }

      # Expect to assign the saved movies to current user's saved movies
      it 'assigns the saved movies of the current user to @saved_movies' do
        saved_movies = user.saved_movies.map(&:movie)
        get :index
        expect(assigns(:saved_movies)).to match_array(saved_movies)
      end

      # Expect to render the index template successfully
      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    # Test cases whenu user is not authenticated
    context 'when user is not authenticated' do

      # Expect to redirect to sign_in path
      it 'redirects to the sign-in page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
