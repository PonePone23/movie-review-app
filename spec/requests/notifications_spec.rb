# spec/reqyests/notifications_controller_spec.rb
require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  # Initial data set up
  let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:0) }
  let(:admin_user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
  after(:each) do
    User.destroy_all
    Notification.destroy_all
    # Add cleanup for other relevant models if needed
  end
  before do
    # Assuming you have a sign_in method available, you can define it in your test_helper
    sign_in user
  end

  # Test cases for index page
  describe 'GET #index' do
    # Expect to return the success http status
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    # Expect to render the index template
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  # Test cases for deleting all notifications
  describe 'POST #delete_all' do
    context 'when notifications exist for the current user' do
      # Expect to delete all notifications
      it 'deletes all notifications' do
        Notification.create(recipient_id: user.id)
        post :delete_all
        expect(Notification.where(recipient_id: user.id)).to be_empty
        expect(response).to redirect_to(notifications_path)
      end
    end

    context 'when no notifications exist for the current user' do
      # Expect to redirect to the notification index page when there is no notifications to be deleted
      it 'redirects to notifications_path with alert' do
        post :delete_all
        expect(response).to redirect_to(notifications_path)
        expect(flash[:alert]).to eq 'No notifications found to delete.'
      end
    end
  end

  # Test cases for deleting single notification
  describe 'DELETE #destroy' do
    # Initial data setup
    let(:notification) { Notification.create(recipient_id: user.id) }
    context 'when notifications exist for the current user' do
      # Expect to delete the selected notification
      it 'deletes notification' do
        Notification.create(recipient_id: user.id)
        post :delete_all
        expect(Notification.where(recipient_id: user.id)).to be_empty
        expect(response).to redirect_to(notifications_path)
        expect(response).to redirect_to(notifications_path)
      end
    end

    context 'when notification does not exist' do
      # Expect to redirect to the notification index page when notification is not found
      it 'redirects to notifications_path with alert' do
        delete :destroy, params: { id: 'invalid_id' }
        expect(response).to redirect_to(notifications_path)
        expect(flash[:alert]).to eq 'Notification not found.'
      end
    end
  end

  # Test cases for fetching admin _user_id
  describe '#admin_user_id' do
    # Expect to return the ID of admin user
    it 'returns the ID of the admin user' do
      allow(User).to receive(:find_by).with(admin: 1).and_return(admin_user)
      expect(controller.admin_user_id).to eq(admin_user.id)
    end
  end
end
