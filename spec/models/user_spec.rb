# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  after(:each) do
    User.destroy_all
    # Add cleanup for other relevant models if needed
  end
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
  # Test CRUD operations of User Model
  describe 'CRUD operations' do

    # Expect user to be valid
    it 'creates a new user' do
      expect(user).to be_valid
    end

    # Find the user by name and expect it to be equal to the original user
    it "reads an existing user" do
      found_user = User.find_by_name(user.name)
      expect(found_user).to eq(user)
    end

    # Update the user name and expect it to be updated successfully
    it "updates an existing user" do
      user.update(name: "John")
      expect(user.reload.name).to eq("John")
    end

    # Expect the count of users to decrease by 1 after deletion
    it "deletes an existing user" do
      user.destroy
      expect(User.exists?(user.id)).to be_falsey
    end

     # Create comments associated with the user and expect them to be deleted along with the user
    it 'deletes associated comments when user is destroyed' do
        comment1 = Comment.create(description: "This is a comment.", status: 1, movie_id: movie.id, user_id: user.id)
        comment2 = Comment.create(description: "This is a comment.", status: 1, movie_id: movie.id, user_id: user.id)
        expect(user.comments).to include(comment1, comment2)
        user.destroy
        expect(User.exists?(user.id)).to be_falsey
        expect(Comment.exists?(comment1.id)).to be_falsey
        expect(Comment.exists?(comment2.id)).to be_falsey
    end

    # Attach an image to the user and expect it to be destroyed along with the user
    it 'destroys attached image when movie is destroyed' do
      image = fixture_file_upload('m01.png', 'image/png')
      user.image.attach(image)
      filename = user.image.filename.to_s
      user.destroy
      expect(User.exists?(user.id)).to be_falsey
      expect(ActiveStorage::Blob.service.exist?(filename)).to be_falsey
    end
  end

  # Test validations of User Model
  describe 'validations' do
    # Expect user to be invalid without a name
    it 'validates presence of name' do
      user = User.create(name: '', email: 'john@example.com', password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    # Expect user to be invalid without email
    it 'validates presence of email' do
      user = User.create(name: 'John', email: '', password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    # Expect user to be invalid with a non-unique email
    it "is invalid with a non-unique email" do
      user = User.create(name: 'John', email: 'john@gmail.com', password: 'password')
      new_user = User.create(name: 'John', email: 'john@gmail.com', password: 'password')
      new_user.valid?
      expect(new_user.errors[:email]).to include("has already been taken")
    end

    # Expect user to be invalid without a password
    it 'validates presence of password' do
      user = User.create(name: 'John', email: 'john@gmail.com', password: '')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    # Expect user to be invalid with a password with length less than 6
    it 'validates minimum length of password' do
      user = User.create(name: 'John', email: 'john@gmail.com', password: '111')
      expect(user).not_to be_valid
    end
  end

  # Test associations of User Model
  describe 'associations' do
      # Expect associations between User and Comment to be has_many
    it 'has many comments with dependent destroy' do
      association = described_class.reflect_on_association(:comments)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    # Expect association between User and attached_image to be has_one
    it 'has one attached image' do
      association = described_class.reflect_on_association(:image_attachment)
      expect(association.macro).to eq(:has_one)
    end

    # Expect association between User and Rating to be has_many
    it 'has many ratings' do
      association = described_class.reflect_on_association(:ratings)
      expect(association.macro).to eq(:has_many)
    end

    # Expect association between User and Notification to be has_many
    it 'has many notifications' do
      association = described_class.reflect_on_association(:notifications)
      expect(association.macro).to eq(:has_many)
    end

    # Expect association between User and Saved_Movie to be has_many
    it 'has many saved_movies' do
      association = described_class.reflect_on_association(:saved_movies)
      expect(association.macro).to eq(:has_many)
    end

    # Expect association between User and Discussion to be has_many
    it 'has many discussions' do
      association = described_class.reflect_on_association(:discussions)
      expect(association.macro).to eq(:has_many)
    end

    # Expect association between User and Reaction to be has_many
    it 'has many reactions' do
      association = described_class.reflect_on_association(:reactions)
      expect(association.macro).to eq(:has_many)
    end

    # Expect association between User and Reply to be has_many
    it 'has many replies' do
      association = described_class.reflect_on_association(:replies)
      expect(association.macro).to eq(:has_many)
    end
  end

  # Test aunthentication of User
  describe 'authentication' do
    # Expect user to be authernticate with valide credentials
    it 'authenticates with valid credentials' do
      user = User.create(name: 'John', email: 'john@gmail.com', password: 'password')
      authenticated_user = User.find_for_authentication(email: user.email)
      expect(authenticated_user.valid_password?('password')).to eq(true)
    end

    # Expect user not to be authenticate with invalid password
    it 'does not authenticate with invalid password' do
      user = User.create(name: 'John', email: 'john@gmail.com', password: 'password')
      authenticated_user = User.find_for_authentication(email: user.email)
      expect(authenticated_user.valid_password?('wrong_password')).to eq(false)
    end
  end

  # Test user account recovrable and rememberable
  describe 'recoverable , rememberable' do

    # Expect user password to be recoverable
    it 'is recoverable' do
      user = User.create(name: 'John', email: 'johny@example.com', password: 'password')
      user.send_reset_password_instructions
      expect(user.reset_password_token).not_to be_nil
      expect(user.reset_password_sent_at).not_to be_nil
    end
  end

  #check for non admin user
  describe ".non_admin_users" do
    # Expect to return the users who are not admin
    it "returns users who are not administrators" do
      admin_user = User.create(name: 'John', email: 'john@admin.com', password: 'password', admin: true)
      non_admin_user1 = User.create(name: 'Jane', email: 'jane1@example.com', password: 'password', admin: false)
      non_admin_user2 = User.create(name: 'Bob', email: 'bob@example.com', password: 'password', admin: false)

      non_admin_users = User.non_admin_users

      expect(non_admin_users).to include(non_admin_user1)
      expect(non_admin_users).to include(non_admin_user2)
      expect(non_admin_users).not_to include(admin_user)
    end
  end

  #check for saved movie
  describe '#saved_movies' do
    # Expect to return the saved_movies for the user
    it 'returns the saved movies for the user' do
      saved_movie = SavedMovie.create(user_id: user.id, movie_id: movie.id)
      expect(user.saved_movies).to include(saved_movie)
    end
  end

  #check for search_by_name
  describe '.search_by_name' do
    # Initial data setup
    let(:user1) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password') }
    let(:user2) { User.create(name: 'Alice Smith', email: 'alice@example.com', password: 'password') }

    # Expec to return the name of the user that match the keyword
    it 'returns users whose name matches the keyword' do
      result = described_class.search_by_name('John')
      expect(result).to include(user1)
      expect(result).not_to include(user2)
    end

    # Expect to return empty results if no user matches the searched keyword
    it 'returns empty result if no user matches the keyword' do
      result = described_class.search_by_name('Jane')
      expect(result).to be_empty
    end
  end
end
