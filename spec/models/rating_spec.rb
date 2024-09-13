# spec/models/comment_spec.rb
require 'rails_helper'

RSpec.describe Comment, type: :model do
  # Define let statements for creating user and movie instances
  let(:user) { User.create(name: 'testuser', email: 'mailto:test@example.com', admin: false) }
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

  # Test cases for association
  describe "Check Association" do
    # Expect the association between the Rating and User to have belongs to
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    # Expect the association between Rating and User to have belongs to
    it 'belongs to a movie' do
      association = described_class.reflect_on_association(:movie)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  # Test for validation
  describe "Check Validation" do
    it 'validates rating is within the range of 1 to 5' do
      rating = Rating.new(user: user, movie: movie)

      # Test for rating less than 1
      rating.rating = 0
      expect(rating).to_not be_valid

      # Test for rating within the range 1..5
      (1..5).each do |valid_rating|
        rating.rating = valid_rating
        expect(rating).to be_valid
      end

      # Test for rating greater than 5
      rating.rating = 6
      expect(rating).to_not be_valid
    end
  end

   # Test max_rating_for_user method
   describe '.max_rating_for_user' do

    # Expect to return maximum rating for a user
    it 'returns the maximum rating for a user' do
      user_rating = Rating.create(user: user, movie: movie, rating: 3)
      Rating.create(user: user, movie: movie, rating: 4)
      Rating.create(user: user, movie: movie, rating: 5)

      max_rating = Rating.max_rating_for_user(user,movie)
      expect(max_rating).to eq(5)
    end

    # Expect to return 0 if user has no rating given
    it 'returns 0 if user has no ratings' do
      max_rating = Rating.max_rating_for_user(user,movie)
      expect(max_rating).to eq(0) # If the user has no ratings, return 5
    end
  end
 end
