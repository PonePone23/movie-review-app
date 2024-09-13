#spec/requests/activity_spec.rb
require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do
  include Devise::Test::ControllerHelpers
  after(:each) do
    User.destroy_all
    Activity.destroy_all
    # Add cleanup for other relevant models if needed
  end
  let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password') }
  let!(:activity) { user.activities.create(action:"Logged In") }

  # Test code for index page
  describe 'GET #index' do
    it 'assigns @users and @activities' do
      get :index
      # Assert that @users and @activities are assigned correctly
      expect(assigns(:users).map(&:id)).to include(user.id)
      expect(assigns(:activities)).to include(activity)

      # Assert that the index template is rendered
      expect(response).to render_template(:index)
    end
  end

  # Delete all activities
  describe 'DELETE #delete_all' do
    context 'when there are activities to delete' do
      # Expect to delete all activites if activities exist
      it 'deletes all activities' do
        delete :delete_all
        expect(Activity.count).to eq(0)
        expect(response).to redirect_to(dashboard_users_path)
        expect(flash[:notice]).to eq('All activities have been deleted.')
      end
    end

    context 'when there are no activities to delete' do
      # Expect to get notice message when there are no activites to be deleted.
      it 'redirects with a notice' do
        Activity.destroy_all
        delete :delete_all
        expect(response).to redirect_to(dashboard_users_path)
        expect(flash[:notice]).to eq('No activities to be deleted.')
      end
    end
  end

  # Delete single activity
  describe 'DELETE #delete_single' do
    # Expect to delete selected activity and get notice message
    it 'deletes a single activity' do
      delete :delete_single, params: { id: activity.id }
      expect(Activity.count).to eq(0)
      expect(response).to redirect_to(dashboard_users_path)
      expect(flash[:notice]).to eq('Activity has been deleted.')
    end
  end

  # Delete user's activities
  describe 'DELETE #delete_user_activities' do

    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password') }

    # Expect all user activites to be deleted
    it 'destroys all activities of a user' do
      expect(User).to receive(:find_by).with(id: user.id.to_s).and_return(user)
      expect(Activity).to receive(:find_by).with(user_id: user.id.to_s).and_return(true)
      expect(user.activities).to receive(:destroy_all)
      delete :delete_user_activities, params: { user_id: user.id }
      expect(response).to redirect_to(dashboard_users_path)
      expect(flash[:notice]).to eq('All activities for the user have been deleted.')
    end

    # Expect to redirect to dashboard when there is no activites to be deleted
    it 'redirects to dashboard with notice if there are no activities for the user' do
      expect(User).to receive(:find_by).with(id: user.id.to_s).and_return(user)
      expect(Activity).to receive(:find_by).with(user_id: user.id.to_s).and_return(false)
      delete :delete_user_activities, params: { user_id: user.id }
      expect(response).to redirect_to(filter_by_user_users_path)
      expect(flash[:notice]).to eq('No activities to be deleted.')
    end

    # Expect to return to the dashboard with notice when user is not found
    it 'redirects to dashboard with notice if user is not found' do
      expect(User).to receive(:find_by).with(id: '999').and_return(nil)
      delete :delete_user_activities, params: { user_id: '999' }
      expect(response).to redirect_to(dashboard_users_path)
      expect(flash[:notice]).to eq('User not found.')
    end
  end
end
