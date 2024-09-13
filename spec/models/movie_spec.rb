# spec/models/movie_spec.rb
require 'rails_helper'

RSpec.describe Movie, type: :model do
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
  # Test CRUD operations of Movie model
  describe 'CRUD operations' do
    # Expect movie to be valid
    it 'creates a new movie' do
      ActiveRecord::Base.transaction do
        expect(movie).to be_valid
      end
    end

    # Find the movie by name and expect it to be equal to the original movie
    it "reads an existing movie" do
      ActiveRecord::Base.transaction do
        found_movie = Movie.find_by_name(movie.name)
        expect(found_movie).to eq(movie)
      end
    end

    # Update the movie name and expect it to be updated successfully
    it "updates an existing movie" do
      ActiveRecord::Base.transaction do
        movie.update(name: "New movie name")
        expect(movie.reload.name).to eq("New movie name")
      end
    end

    # Expect the count of movies to decrease by 1 after deletion
    it "deletes an existing movie" do
      ActiveRecord::Base.transaction do
        movie.destroy
        expect(Movie.exists?(movie.id)).to be_falsey
      end
    end

    # Create comments associated with the movie and expect them to be deleted along with the movie
    it 'deletes associated comments when movie is destroyed' do
      ActiveRecord::Base.transaction do
        comment1 = Comment.create(description: "This is a commment.", status:1, movie:movie, user:user)
        comment2 = Comment.create(description: "This is a commment.", status:1, movie:movie, user:user)
        expect(movie.comments).to include(comment1, comment2)
        movie.destroy
        expect(Movie.exists?(movie.id)).to be_falsey
        expect(Comment.exists?(comment1.id)).to be_falsey
        expect(Comment.exists?(comment2.id)).to be_falsey
      end
    end

    # Attach an image to the movie and expect it to be destroyed along with the movie
    it 'destroys attached image when movie is destroyed' do
      ActiveRecord::Base.transaction do
        filename = movie.image.filename.to_s
        movie.destroy
        expect(Movie.exists?(movie.id)).to be_falsey
        expect(ActiveStorage::Blob.service.exist?(filename)).to be_falsey
      end
    end
  end

  # Test assiciations of Movie model
  describe 'associations' do
    # Expect the association between movies and genres to be has_and_belongs_to_many
    it 'has and belongs to genres' do
      ActiveRecord::Base.transaction do
        association = described_class.reflect_on_association(:genres)
        expect(association.macro).to eq(:has_and_belongs_to_many)
      end
    end

    # Expect the association between movies and users to be belongs_to
    it 'belongs to a user' do
      ActiveRecord::Base.transaction do
        association = described_class.reflect_on_association(:user)
        expect(association.macro).to eq(:belongs_to)
      end
    end

    # Expect the association between movies and comments to be has_many with dependent destroy
    it 'has many comments with dependent destroy' do
      ActiveRecord::Base.transaction do
        association = described_class.reflect_on_association(:comments)
        expect(association.macro).to eq(:has_many)
        expect(association.options[:dependent]).to eq(:destroy)
      end
    end

    # Expect the association between movies and attached images to be has_one
    it 'has one attached image' do
      ActiveRecord::Base.transaction do
        association = described_class.reflect_on_association(:image_attachment)
        expect(association.macro).to eq(:has_one)
      end
    end
  end

  # Test validations of Movie model
  describe 'validations' do
    # Expect the movie to be invalid without a name
    it 'validates presence of name' do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      genre1 = Genre.create(name: 'Action')
      genre2 = Genre.create(name: 'Comedy')
      movie = Movie.create(
        name: nil,
        review: 'This is a review of movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
      expect(movie).not_to be_valid
      expect(movie.errors[:name]).to include("can't be blank")
    end

    # Expect movie to have a unique name
    it 'validates presence of review' do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      genre1 = Genre.create(name: 'Action')
      genre2 = Genre.create(name: 'Comedy')
      movie1 = Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
      movie2 = Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
      expect(movie2).not_to be_valid
      expect(movie2.errors[:name]).to include("has already been taken")
    end

    # Expect movie to be invalid without review
    it 'validates presence of review' do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      genre1 = Genre.create(name: 'Action')
      genre2 = Genre.create(name: 'Comedy')
      movie = Movie.create(
        name: 'Sample Movie',
        review: nil,
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
      expect(movie).not_to be_valid
      expect(movie.errors[:review]).to include("can't be blank")
    end

    # Expect movie to be invalid without release date
    it 'validates presence of release date' do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      genre1 = Genre.create(name: 'Action')
      genre2 = Genre.create(name: 'Comedy')
      movie = Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of movie.',
        release_date: nil,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
      expect(movie).not_to be_valid
      expect(movie.errors[:release_date]).to include("can't be blank")
    end

    # Expect movie to be invalid without duration
    it 'validates presence of duration' do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      genre1 = Genre.create(name: 'Action')
      genre2 = Genre.create(name: 'Comedy')
      movie = Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of movie.',
        release_date: Date.today,
        duration: nil,
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
      expect(movie).not_to be_valid
      expect(movie.errors[:duration]).to include("can't be blank")
    end

    # Expect movie to be valid with at least one genre
    it "is valid with at least one genre" do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      genre1 = Genre.create(name: 'Action')
      genre2 = Genre.create(name: 'Comedy')
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
      expect(movie).to be_valid
    end

    # Expect movie to be invalid without any genres
    it "is invalid without any genres" do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      genre1 = Genre.create(name: 'Action')
      genre2 = Genre.create(name: 'Comedy')
      movie = Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: nil,
        image: fixture_file_upload('m01.png', 'image/png')
      )
      expect(movie).to be_invalid
      expect(movie.errors[:genres]).to include("must be present")
    end

    # Validates presence of trailer_url
    it "is invalid without trailer_url" do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      genre1 = Genre.create(name: 'Action')
      genre2 = Genre.create(name: 'Comedy')
      movie = Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: nil,
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
      expect(movie).to be_invalid
      expect(movie.errors[:trailer_url]).to include("can't be blank")
    end

    # Validates presence of image
    it "is invalid without image" do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      genre1 = Genre.create(name: 'Action')
      genre2 = Genre.create(name: 'Comedy')
      movie = Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
      )
      expect(movie).to be_invalid
      expect(movie.errors[:image]).to include("can't be blank")
    end
  end

  describe '.released_in_year' do
    let(:movie_2000) do
      Movie.create(
        name: 'Sample Movie 2000',
        release_date: '2000-01-01',
        review: 'This is a review of movie.',
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
        # Add other attributes as needed
      )
    end

    let(:movie_2001) do
      Movie.create(
        name: 'Sample Movie 2001',
        release_date: '2001-01-01',
        review: 'This is a review of movie.',
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
        # Add other attributes as needed
      )
    end
    let(:movie_2002) do
      Movie.create(
        name: 'Sample Movie 2002',
        release_date: '2002-01-01',
        review: 'This is a review of movie.',
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end

    it 'returns movies released in the specified year' do
      movies_in_2000 = described_class.released_in_year(2000)
      expect(movies_in_2000).to include(movie_2000)
      expect(movies_in_2000).not_to include(movie_2001, movie_2002)
    end

    it 'does not return movies from other years' do
      movies_in_2001 = described_class.released_in_year(2001)
      expect(movies_in_2001).to include(movie_2001)
      expect(movies_in_2001).not_to include(movie_2000, movie_2002)
    end

    it 'handles invalid year gracefully' do
      movies_in_invalid_year = described_class.released_in_year('invalid')
      expect(movies_in_invalid_year).to be_empty
    end
  end

  describe '.search_by_keyword' do

    let(:movie_1) do
      Movie.create(
        name: 'The Matrix',
        release_date: '2000-01-01',
        review: 'This is a review of movie.',
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png'),
        casts: 'Keanu Reeves', director: 'Lana Wachowski', country: 'USA'
        # Add other attributes as needed
      )
    end
    let(:movie_2) do
      Movie.create(
        name: 'Inception',
        release_date: '2000-01-01',
        review: 'This is a review of movie.',
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png'),
        casts: 'Leonardo DiCaprio', director: 'Christopher Nolan', country: 'USA'
        # Add other attributes as needed
      )
    end
    let(:movie_3) do
      Movie.create(
        name: 'Titanic',
        release_date: '2000-01-01',
        review: 'This is a review of movie.',
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre1.id, genre2.id],
        image: fixture_file_upload('m01.png', 'image/png'),
        casts: 'Leonardo DiCaprio', director: 'James Cameron', country: 'USA'
        # Add other attributes as needed
      )
    end

    it 'returns movies that match the keyword in name, casts, director, or country' do
      result = described_class.search_by_keyword('Leonardo')
      expect(result).to include(movie_2, movie_3)
      expect(result).not_to include(movie_1)
    end

    it 'returns an empty array if no movie matches the keyword' do
      result = described_class.search_by_keyword('Nonexistent')
      expect(result).to be_empty
    end
  end
end
