require 'rails_helper'

RSpec.describe DiscussionsController, type: :controller do
  include Devise::Test::ControllerHelpers
  after(:each) do
    User.destroy_all
    Discussion.destroy_all
    # Add cleanup for other relevant models if needed
  end

  # Set up initial data
  let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password') }
  let(:discussion) { Discussion.create(user_id: user.id , content: 'Discussion content') }
  before(:each) do
    sign_in user
  end

  # Test cases for index page
  describe 'GET #index' do
    # Expect to render index template
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  # Test cases for show page
  describe 'GET #show' do
    let(:discussion) { Discussion.create(content: "This is content.", user_id: user.id) }

    # Expect to render the show template
    it 'renders the show template' do
      get :show , params: { id: discussion.id }
      expect(response).to be_successful
    end
  end

  # Test cases for new page
  describe 'GET #new' do
    # Expect to render the new template
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  # Test cases for creating new discussion
  describe 'POST #create' do
    # Test cases with valid parameters for creating new discussion
    context 'with valid attributes' do
      # Expect to create a new discussion
      it 'creates a new discussion' do
        sign_in user
        expect {
          post :create, params: { discussion: { content: 'Test content' } }
        }.to change(Discussion, :count).by(1)
        expect(response).to redirect_to(discussions_url)
      end
    end

    # Test cases with invalid parameter for creating new disucssion
    context 'with invalid attributes' do
      # Expect not to create new discussion with blank content
      it 'does not create a new discussion' do
        sign_in user
        expect {
          post :create, params: { discussion: { content: nil } }
        }.not_to change(Discussion, :count)
        expect(response).to render_template(:new)
      end
    end
  end

  # Test cases for updating the existing discussion
  describe 'PATCH #update' do
    #  Test cases with valid parameter
    context 'with valid attributes' do
      # Expect to update the existing discussion with valid parameter
      it 'updates the discussion' do
        patch :update, params: { id: discussion.id, discussion: { content: 'Updated content' } }
        discussion.reload
        expect(discussion.content).to eq('Updated content')
        expect(response).to redirect_to(discussion)
        expect(flash[:notice]).to eq('Discussion was successfully updated.')
      end
    end

    # Test cases with invalid parameter
    context 'with invalid attributes' do
      # Expect not to update the existing discussion with invalid parameter
      it 'does not update the discussion' do
        patch :update, params: { id: discussion.id, discussion: { content: nil } }
        discussion.reload
        expect(discussion.content).not_to be_nil
        expect(response).to render_template(:edit)
      end
    end
  end

  # Test cases for deleting the existing discussion
  describe 'DELETE #destroy' do
    # Expect to destroy the disscussion
    it 'destroys the discussion' do
      discussion # Ensure the discussion is created before the test
      expect {
        delete :destroy, params: { id: discussion.id }
      }.to change(Discussion, :count).by(-1)
    end

    # Expect to return to the discussion index page with notice message 
    it 'redirects to discussions index page with notice' do
      delete :destroy, params: { id: discussion.id }
      expect(response).to redirect_to(discussions_url)
      expect(flash[:notice]).to eq('Discussion was successfully destroyed.')
    end
  end
end
