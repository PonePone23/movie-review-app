# spec/models/comment_spec.rb
require 'rails_helper'

RSpec.describe Comment, type: :model do
   # Set up initial data
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
    #testing CRUD Opeartion
    describe 'CRUD Operation' do
        #create a comment
        it 'creates a comment' do
          comment = Comment.create(
            description: "This is a comment.",
            status: 1,
            movie_id: movie.id, # Associate the comment with a movie
            user_id: user.id
          )
          expect(comment).to be_valid
          expect(Comment.find(comment.id)).to eq(comment)
        end

        #read a comment
        it 'read comment' do
          comment = Comment.create(description: "This is a comment.", status: 1, movie_id: movie.id, user_id: user.id)
          expect(Comment.find(comment.id)).to eq(comment)
        end

        #delete a comment
        it 'delete comment' do
          comment = Comment.create(description: "This is a comment.", status: 1, movie_id: movie.id, user_id: user.id)
          comment.destroy
          expect(Comment.count).to eq(0)
        end
    end

    #testing validation
    describe 'validation' do
      #testing with blank
      it 'descripatoin cannot be blank' do
        comment = Comment.create(description: "", status: 1, movie_id: movie.id, user_id: user.id)
        expect(comment.errors[:description]).to include("can't be blank")
      end

      #testing with minimum character
      it 'at least 10 minimum character length' do
        comment = Comment.create(description: "", status: 1, movie_id: movie.id, user_id: user.id)
        expect(comment.errors[:description]).to include("is too short (minimum is 10 characters)")
      end
    end

    #testing association
    describe 'associations' do
      #a comment belongs to a user
      it 'belongs to a user' do
        association = Comment.reflect_on_association(:user)
        expect(association.macro).to eq :belongs_to
      end

      #a comment belongs to a movie
      it 'belongs to a movie' do
        association = Comment.reflect_on_association(:movie)
        expect(association.macro).to eq :belongs_to
      end
    end
end
