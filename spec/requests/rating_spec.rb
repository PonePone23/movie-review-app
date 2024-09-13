#spec/requests/rating_spec.rb
require 'rails_helper'

RSpec.describe RatingsController, type: :controller do
  # Include Devise test helpers to sign in a user
  include Devise::Test::ControllerHelpers

  after(:each) do
    Movie.destroy_all
    Genre.destroy_all
    User.destroy_all
    Rating.destroy_all
    # Add cleanup for other relevant models if needed
  end

  # Initial data set up
  let(:user) { User.create(name: 'testuser', email: 'test@example.com', password: 'password') }
  let(:genre1) { Genre.create(name: 'Action') }
  let(:genre2) { Genre.create(name: 'Adventure') }
  let(:movie) { Movie.create(
    name: 'Sample Movie',
    review: 'This is a review of movie.',
    release_date: Date.today,
    duration: '1h 22m',
    trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
    user: user,
    genre_ids: [genre1.id, genre2.id],
    image: fixture_file_upload('m01.png', 'image/png')
  ) }

  # Sign in the user before each test
  before(:each) do
    sign_in user
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      # Expect to create a new rating
      it 'creates a new rating' do
        # Make a POST request to create a new rating
        post :create, params: { movie_id: movie.id, user_id: user.id,rating: { rating: 4 } }

        # Expect that a rating is created
        expect(Rating.count).to eq(1)
      end

      # Expect to redirect to the movie page
      it 'redirects to the movie page with a success notice' do
        # Make a POST request to create a new rating
        post :create, params: { movie_id: movie.id, user_id: user.id, rating: { rating: 4 } }

        # Expect that the user is redirected to the movie page with a success notice
        expect(response).to redirect_to(movie_path(movie))
        expect(flash[:notice]).to eq('Rating Added!')
      end

      # Expect to upadate the existing rating
      it 'update existing rating pass' do
        sign_in user
        exist_rating = Rating.create(movie_id: movie.id, user_id: user.id, rating: 4)
        post :create, params: { movie_id: movie.id, user_id: user.id, rating: { rating: 5 } }
        expect(response).to redirect_to(movie)
        expect(flash[:notice]).to eq('Your rating has been updated.')
        expect(movie.ratings.find_by(user: user).rating).to eq(5)
      end

      # Expect not to update the exisiting rating when fails during rating updating
      it 'update existing rating fails' do
        sign_in user
        exist_rating = Rating.create(movie_id: movie.id, user_id: user.id, rating: 4)
        allow_any_instance_of(Rating).to receive(:update).and_return(false)
        post :create, params: { movie_id: movie.id, user_id: user.id, rating: { rating: 5 } }
        expect(response).to redirect_to(movie)
        expect(flash[:alert]).to eq('Failed to update your rating.')
      end
    end

    context 'with invalid parameters' do
      # Expect not to create a new rating
      it 'does not create a new rating' do
        # Make a POST request to create a new rating with invalid parameters
        post :create, params: { movie_id: movie.id,user_id: user.id, rating: { rating: 6 } }

        # Expect that no rating is created
        expect(Rating.count).to eq(0)
      end

      # Expect to redirect the movie page with alert message
      it 'redirects to the movie page with an alert' do
        # Make a POST request to create a new rating with invalid parameters
        post :create, params: { movie_id: movie.id,user_id: user.id, rating: { rating: 6 } }

        # Expect that the user is redirected to the movie page with an alert
        expect(response).to redirect_to(movie_path(movie))
        expect(flash[:alert]).to eq('Rating could not be added!')
      end
    end
  end

  # Test cases for deleting the existing rating
  describe 'DELETE #destroy' do
    # Expect to destroy the rating
    it 'destroys the rating' do
      sign_in user
      rating = Rating.create(movie_id: movie.id, user_id: user.id, rating: 4)
      movie_id_before_destruction = rating.movie_id
      expect {
        delete :destroy, params: { movie_id: movie.id, user_id: user.id, id: rating.id }
      }.to change { Rating.count }.by(-1)
      expect(response).to redirect_to(movie)
      expect(rating.movie_id).to eq(movie_id_before_destruction)
      expect(flash[:notice]).to eq('Rating has been successfully removed.')
    end

    # Expect not to delete the rating when fails
    it 'fail to destroy the rating' do
      rating = Rating.create(movie_id: movie.id, user_id: user.id, rating: 5)
      allow_any_instance_of(Rating).to receive(:destroy).and_return(false)
      delete :destroy, params: {  movie_id: movie.id, user_id: user.id,id: rating.id }
      expect(response).to redirect_to(movie)
      expect(flash[:alert]).to eq('Failed to remove the rating.')
    end
  end
end
