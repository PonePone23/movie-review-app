#spec/requests/reply_spec.rb
require 'rails_helper'

RSpec.describe RepliesController, type: :controller do
  include Devise::Test::ControllerHelpers
  after(:each) do
    User.destroy_all
    Discussion.destroy_all
    Reply.destroy_all
    # Add cleanup for other relevant models if needed
  end

  # Initial data set up
  let(:user) { User.create(name:"John", email: 'test@example.com', password: 'password') }
  let(:discussion) { Discussion.create(user_id: user.id, content: 'Discussion content') }

  before(:each) do
    sign_in user
  end

  # Test cases for creating new reply
  describe 'POST #create' do
    # With valid parameter for reply
    context 'with valid attributes' do
      # Expect to create a new reply
      it 'creates a new reply' do
        expect {
          post :create, params: { user_id: user.id, discussion_id: discussion.id, reply: { content: 'Test reply content' } }
        }.to change(Reply, :count).by(1)
        expect(response).to redirect_to(discussion)
        expect(flash[:notice]).to eq('Reply was successfully created.')
      end
    end

    # With invalid parameter for Reply
    context 'with invalid attributes' do
      # Expect not to create a new reply
      it 'does not create a new reply' do
        expect {
          post :create, params: { user_id: user.id, discussion_id: discussion.id, reply: { content: nil } }
        }.not_to change(Reply, :count)
        expect(response).to redirect_to(discussion)
        expect(flash[:alert]).to eq('Failed to create reply.')
      end
    end
  end

  # Test cases for deleting
  describe 'DELETE #destroy' do
    # Initial data set up
    let!(:reply) { Reply.create(content: 'Test reply', user: user, discussion: discussion) }

    # Expet to delete the reply
    it 'deletes the reply' do
      allow(controller).to receive(:current_user).and_return(user)
      expect {
        delete :destroy, params: { discussion_id: discussion.id, id: reply.id }
      }.to change(Reply, :count).by(-1)
    end

    # Expect to redirect to discussion index page
    it 'redirects to the discussion page' do
      allow(controller).to receive(:current_user).and_return(user)
      delete :destroy, params: { discussion_id: discussion.id, id: reply.id }
      expect(response).to redirect_to(discussion_path(discussion))
    end
  end
end
