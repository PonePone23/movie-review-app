# spec/requests/comment_spec.rb
require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  include Devise::Test::ControllerHelpers
  after(:each) do
    Movie.destroy_all
    Genre.destroy_all
    User.destroy_all
    # Add cleanup for other relevant models if needed
  end
   # Set up initial data
   let(:user){
    User.create(email:"user@gmail.com",password:"123123",name:"user")
  }
  let(:admin){
    User.create(email:"admin@admin.com",password:"123123",name:"admin", admin:1)
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
  # Testing comment create is working
  describe 'POST #create' do
    #when user is admin
    context 'when user is an admin' do
      #sTesting to create a comment with a true status
      it 'creates a comment with status true' do
        sign_in admin
        comment_params = { description: 'This is a valid comment.' }
        expect {
          post :create, params: { movie_id: movie.id, user_id: admin.id, comment: comment_params }
        }.to change(Comment, :count).by(1)
        expect(response).to redirect_to(movie_path(movie))
        expect(flash[:notice]).to eq('Review was successfully created.')
      end
    end

    # Expect to send notifications to admins when user create a comment
    it 'sends notifications to admins' do
      sign_in user
      comment_params = { description: 'This is a valid comment.' }
      expect {
        post :create, params: { movie_id: movie.id, user_id: user.id, comment: comment_params }
      }.to change(Notification, :count).by(User.where(admin: true).count)
    end

    #when user is not an admin
    context 'when user is not an admin' do
      #testing to create a comment with a true status
      it 'creates a comment with status false' do
        sign_in user
        comment_params = { description: 'This is a valid comment.' }
        expect {
          post :create, params: { movie_id: movie.id, user_id: user.id, comment: comment_params }
        }.to change(Comment, :count).by(1)
        expect(Comment.last.status).to be_falsey
        expect(response).to redirect_to(movie_path(movie))
        expect(flash[:notice]).to eq('Your Review is pending. Admin will approve it soon.')
      end
    end

    #creating with an invalid params
    context 'create comment with invalid params' do
      #testing with a blank description
      it 'renders form with error message if comment is not valid' do
        post :create, params: { movie_id: movie.id, user_id: user.id, comment: { content: '' } }
        expect(assigns(:comment)).not_to be_persisted
        expect(assigns(:error_message)).to eq('Review cannot be blank and must be at least 10 characters.')
      end
    end

    #roll back data when fails to create
    it "fails to create the comment and rolls back the transaction" do
      allow_any_instance_of(Comment).to receive(:save).and_raise(StandardError.new('Unexpected error'))
      expect{
      post :create, params: { movie_id: movie.id, user_id: user.id, comment: {description:""} }
    }.to raise_error(ActiveRecord::Rollback)
    end
  end

  #destory a comment
  describe 'DELETE #destroy' do

    let!(:comment) { Comment.create(description: 'Test comment', movie: movie, user: user) }
    let(:comment) { Comment.create(description: 'Test comment', movie: movie, user: user) }
    before do
      allow(Movie).to receive(:find).and_return(movie)
      allow(Comment).to receive(:new).and_raise(StandardError, 'Something went wrong')
    end
    #deleting a comment
    it 'destroys the comment' do
      sign_in user
      expect {
        delete :destroy, params: { movie_id: movie.id, user_id: user.id, id: comment.id }
      }.to change(Comment, :count).by(-1)
      expect(Notification.last.recipient).to eq(user)
      expect(Notification.last.actor).to eq(user)
      expect(Notification.last.action).to eq('deleted_comment')
      expect(response).to redirect_to(movie_path(movie))
      expect(flash[:notice]).to eq('Review was successfully deleted.')
    end
    it "creates activity for current user" do
      sign_in user
      delete :destroy, params: { movie_id: movie.id, user_id: user.id, id: comment.id }
      expect(user.activities.last.action).to eq("Deleted review in '#{movie.name}'")
    end

    it "destroy comment fails" do
      sign_in user
      allow_any_instance_of(Comment).to receive(:destroy).and_return(false)
      delete :destroy, params: { movie_id: movie.id, user_id: user.id, id: comment.id }
      expect(response).to redirect_to(movie_path(movie))
      expect(flash[:alert]).to eq('Error deleting review.')
    end
  end

  #testing a approve method in controller
  describe 'PATCH #approve' do
    let!(:comment) { Comment.create(description: 'Test comment', movie: movie, user: user) }
      #when comment approvals success
      context 'when comment approvals success' do
        #admin approve a comment and status has to be true
        it 'approves the comment' do
          patch :approve, params: { movie_id: movie.id, user_id: user.id, id: comment.id }
          expect(comment.reload.status).to be_truthy
          expect(response).to redirect_to(movie_path(movie, user))
          expect(flash[:notice]).to eq('Review approved successfully.')
        end
      end

      #when comment approval fails
      context 'when comment approval fails' do
        #admin approve a comment and status has to be false
        it 'does not approve the comment' do
          allow_any_instance_of(Comment).to receive(:update).and_return(false)
          patch :approve, params: { movie_id: movie.id, user_id: user.id, id: comment.id }
          expect(response).to redirect_to(movie_path(movie, user))
          expect(flash[:notice]).to eq('Review could not be updated.')
        end
      end
  end

  describe 'find admin' do
      let(:admin_user) { User.create(email:"admin@admin.com",password:"123123",name:"admin", admin:1) }

      it 'returns nil if there is no admin user' do
        admin_user.update(admin: false)

        expect(controller.send(:admin_user_id)).to be_nil
      end
  end
end
