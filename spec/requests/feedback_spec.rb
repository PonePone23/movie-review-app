# spec/requests/feedback_spec.rb
require 'rails_helper'

RSpec.describe FeedbacksController, type: :controller do
  # Test cases for GET #new action
  describe 'GET #new' do
    # Expect to assign a new feedback
    it 'assigns a new feedback as @feedback' do
      get :new
      expect(assigns(:feedback)).to be_a_new(Feedback)
    end

    # Expect to render the new template
    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  # Test cases for POST #create action
  describe 'POST #create' do
    # Test cases with valid feedbacl parameter
    context 'with valid params' do
      # Set up feedbacl valid parameter
      let(:valid_params) { { feedback: { name: 'John Doe', email: 'john@example.com', message: 'Test message' } } }

      # Expect to create new feedback
      it 'creates a new Feedback' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change(Feedback, :count).by(1)
      end

      # Expect to get JSON response with success message
      it 'renders a JSON response with success message' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to eq(true)
      end
    end

    # Test cases with invalid parameter
    context 'with invalid params' do
      # Set up initial data for test
      let(:invalid_params) { { feedback: { name: '', email: 'invalid_email', message: '' } } }

      # Expect feedback not to be created with invalid parameter
      it 'does not save the new feedback' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change(Feedback, :count)
      end

      # Expect to get error messages
      it 'renders a JSON response with errors' do
        post :create, params: invalid_params, format: :json
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['errors']).not_to be_empty
      end
    end

    context "when an error occurs during feedback creation" do
      let(:valid_params) { { feedback: { name: 'John Doe', email: 'john@example.com', message: 'Test message' } } }

      # To handle exceptions
      it "handles exceptions" do
        allow(Feedback).to receive(:new).and_raise(StandardError, "Test error message")
        expect {
          post :create, params: valid_params, format: :json
        }.to raise_error(ActiveRecord::Rollback)
      end
    end
  end
end
