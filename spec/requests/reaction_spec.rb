#spec/requeswts/reaction_spec.rb
require 'rails_helper'

RSpec.describe ReactionsController, type: :controller do

  include Devise::Test::ControllerHelpers
  after(:each) do
    User.destroy_all
    Discussion.destroy_all
    Reaction.destroy_all
    # Add cleanup for other relevant models if needed
  end

  # Initial data set up
  let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password') }
  let(:discussion) { Discussion.create(user_id: user.id , content: 'Discussion content') }
  let(:reaction) { Reaction.new(user: user, discussion: discussion) }

  # Test cases for creating new reaction
  describe 'POST #create' do
    context 'with valid attributes' do
      # Expect to create new reaction
      it 'creates a new reaction' do
        sign_in user
        expect {
          post :create, params: { user_id: user.id, discussion_id: discussion.id, reaction: { reaction_type: 'like' } }
        }.to change(Reaction, :count).by(1)
        expect(response).to redirect_to(discussion)
      end
    end


    context 'with invalid attributes' do
      # Expect not to create a new reaction
      it 'does not create a new reaction' do
        sign_in user
        expect {
          post :create, params: { user_id: user.id, discussion_id: discussion.id, reaction: { reaction_type: nil } }
        }.not_to change(Reaction, :count)
        expect(response).to redirect_to(discussion)
      end

      # Expect to render the new template
      it 'renders the new template' do
        sign_in user
        post :create, params: { user_id: user.id, discussion_id: discussion.id, reaction: { reaction_type: nil } }
        expect(response).to redirect_to(discussion)
      end
    end
  end

  # Test cases for fetching user name
  describe '#user_name' do
    # When user is present
    context 'when user is present' do
      # Expect to return the name of user
      it 'returns the name of the associated user' do
        expect(reaction.user_name).to eq('John Doe')
      end
    end

    # When user is not present
    context 'when user is not present' do
      # Expect to return nil
      it 'returns nil' do
        reaction.user = nil
        expect(reaction.user_name).to be_nil
      end
    end
  end
end
