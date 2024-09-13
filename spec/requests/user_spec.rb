# spec/requests/user_spec.rb
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # devise test helpers for authentication
  include Devise::Test::ControllerHelpers
  after(:each) do
    Movie.destroy_all
    Genre.destroy_all
    User.destroy_all
    Activity.delete_all
    # Add cleanup for other relevant models if needed
  end
  # define let blocks to create users for testing
  let(:tester) { User.create(name: "Tester", email: "test@example.com", password: "password",admin: true)}
  let(:user1) { User.create(name: "John", email: "john@example.com", password: "password") }
  let(:user2) { User.create(name: "Jane", email: "jane@example.com", password: "password") }
  # before each test, sign in the tester
  before(:each) do
   sign_in tester
  end
  # check index action
  describe "GET #index" do
    context "when user is authenticated" do
      # Expect to assign the users
      it "assigns @users" do
        get :index
        expected_user = [user2, user1,tester].sort_by(&:name)
        expect(assigns(:users)).to eq(expected_user)
      end

      # Expect to render the index tempate
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end

      # Expect to show 10 users per page with pagination
      it "assigns paginated users with a page size of 10 in name order" do
        users = (1..20).map do |n|
          User.create(name: "Jane#{n}", email: "jane#{n}@example.com", password: "password")
        end
        (1..(users.length / 10)).each do |page|
          get :index, params: { page: page }
          expected_users = users.sort_by(&:name)[((page - 1) * 10)...(page * 10)]
          expect(assigns(:users)).to eq(expected_users)
        end
      end
    end
  end

  # Check new_registration action
  describe "GET #new_registration" do
    # Expect to assign the new user
    it "assigns a new user to @user" do
      get :new_registration
      expect(assigns(:user)).to be_a_new(User)
    end

    # Expect to render the new_registration template
    it "renders the new_registration template" do
      get :new_registration
      expect(response).to render_template("new_registration")
    end
  end

  # Check create_registration action
  describe "POST #create_registration" do
    # With valid parameter
    context "with valid params" do
      # Initial data set up
      let(:valid_params) {
        { user: { name: "Johny", email: "johny@example.com", password: "password", password_confirmation: "password" ,admin: false } }
      }
      # Expect to create a new user
      it "creates a new user" do
        expect {
          post :create_registration, params: valid_params
        }.to change(User, :count).by(1)
      end

      # Expect to redirect to the index page with notice
      it "redirects to the index page with success notice" do
        post :create_registration, params: valid_params
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to eq('User was successfully created.')
      end
    end

    # With invalid parameter
    context "with invalid params" do
      # Initial data set up
      let(:invalid_params) {
        { user: { name: "", email: "invalid_email", password: "password", password_confirmation: "password" } }
      }

      # Expect to render the new_registration page
      it "renders the new_registration template with unprocessable entity status" do
        post :create_registration, params: invalid_params
        expect(response).to render_template(:new_registration)
        expect(response.status).to eq(422)
      end
    end

    # Test cases with admin email
    context 'with admin email' do
      # Expect to create admin user
      it 'creates an admin user' do
        post :create_registration, params: { user: { email: 'admin@admin.com', admin: 'true' } }
        expect(User.last.admin).to be_truthy
      end
    end

    context 'when an error occurs during user creation' do
      # Expect to raise ActiveRecored error when an error occurs while creating user
      it 'does not create the user and logs the error' do
        expect(Rails.logger).to receive(:error).with(/Error occurred while creating user/)
        allow_any_instance_of(User).to receive(:save).and_raise(StandardError.new('Some error'))

        expect {
          post :create_registration, params: { user: { email: 'user@example.com', admin: 'false' } }
        }.to raise_error(ActiveRecord::Rollback)

        expect(response).to redirect_to(new_registration_path)
        expect(flash[:alert]).to eq('Failed to create User. An error occurred while processing your request.')
      end
    end
  end

   # Check edit action
  describe "GET #edit" do
    # Initial data set up
    let!(:user) { User.create(name: "Johny", email: "johny@example.com", password: "password") } # Create a user for testing

    # Expect to assign the user
    it "assigns the requested user to @user" do
      get :edit, params: { id: user.id }
      expect(assigns(:user)).to eq(user)
    end

    # Expect to render the edit template
    it "renders the edit template" do
      get :edit, params: { id: user.id }
      expect(response).to render_template("edit")
    end
  end

  # Check update action
  describe "PATCH #update" do
    # Test cases when password is present
    context "when password is present" do
      # Expect to update the user's information
      it "updates the user's information" do
        new_name = "Updated Name"
        patch :update, params: { id: tester.id, user: { name: new_name, password: "new_password", password_confirmation: "new_password" } }
        tester.reload
        expect(tester.name).to eq(new_name)
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to eq("User was successfully updated!")
      end
    end

    # Test cases when user is not present
    context "when password is not present" do

      # Expect to update the user's information
      it "updates the user's information" do
        patch :update, params: { id: tester.id, user: { name: "New Name" } }
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to eq("User information was successfully updated!")
      end
    end

    # When admin update the information
    context 'when admin updates user information' do
      # Expect to update the user's information
      it 'updates user information' do
        put :update, params: { id: user1.id, user: { name: 'new_username' } }
        user1.reload
        expect(user1.name).to eq('new_username')
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to eq('User information was successfully updated!')
      end
    end

    context 'when unauthorized user tries to update information' do
      # Expect to redirect to the root page
      it 'redirects with notice' do
        sign_in user1
        put :update, params: { id: user2.id, user: { name: 'new_username' } }
        expect(response).to redirect_to(root_path)
        end
    end

    context 'when an error occurs during update' do
      # Expect to get alert message when an errro occurs during update
      it 'redirects with alert and logs the error' do
        allow(User).to receive(:find).and_return(user1)
        allow(user1).to receive(:update).and_raise(StandardError, 'Test error message')

        expect(Rails.logger).to receive(:error).with(/Error occurred while updating user/)

        expect {
          put :update, params: { id: user1.id, user: { name: 'new_username' } }
        }.to raise_error(ActiveRecord::Rollback)
        expect(response).to redirect_to(edit_user_path(user1))
        expect(flash[:alert]).to eq('Failed to update User. An error occurred while processing your request.')
      end
    end
  end

  # Check destroy action
  describe "DELETE #destroy" do
    # Expect to deltet the user and redirect to users index page
    it "deletes the user and redirects to the users index page with success notice" do
      expect {
        delete :destroy, params: { id: tester.id }
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(users_path)
      expect(flash[:notice]).to eq("Account has been successfully deleted.")
    end

    # Expec to rediect to the user profile page
    it "redirects to the user's profile page with alert message if unable to delete the account" do
      allow_any_instance_of(User).to receive(:destroy).and_return(false)
      delete :destroy, params: { id: tester.id }
      expect(response).to redirect_to(user_path(tester))
      expect(flash[:alert]).to eq("Unable to delete the account. Please try again.")
    end

    # Expect to raise ActiveRecord error when an error occurs during deletion
    it 'redirects with alert when an error occurs during deletion' do
      allow(User).to receive(:find).and_return(user1)
      allow(user1).to receive(:destroy).and_raise(StandardError, 'Test error message')

      # Expect the Rails logger to receive the error message
      expect(Rails.logger).to receive(:error).with(/Error occurred while deleting user/)

      expect{
        delete :destroy, params: { id: user1.id }
      }.to raise_error(ActiveRecord::Rollback)

      # Assert the response
      expect(response).to redirect_to(users_path)
      expect(flash[:alert]).to eq('Failed to delete User. An error occurred while processing your request.')
    end

  end
   # Check search action
  describe "GET #search" do
      # Expect to return ther users list that matches the search parameter
      it "returns users matching the search query" do
        user1 = User.create(name: "John Doe", email: "doe@example.com", password: "password")
        user2 = User.create(name: "Jane Smith", email: "smith@example.com", password: "password")
        get :search, params: { search: "John" }
        expect(assigns(:results)).to include(user1)
        expect(assigns(:results)).not_to include(user2)
      end

      # Expect to downcases the search parameter
      it "downcases the search parameter" do
        get :search, params: { search: "JOHN" }
        expect(assigns(:parameter)).to eq("john")
      end

      # Expect to render the search template
      it "renders the search template" do
        get :search, params: { search: "John" }
        expect(response).to render_template("search")
      end

    context "with blank search parameter" do
      # Expect to redirect to the root path
      it "redirects to root path" do
        get :search, params: { search: "" }
        expect(response).to redirect_to( users_path)
      end
    end
  end

  # Check post action
  describe "POST #import" do
    context "with valid file" do
      let(:file) { fixture_file_upload('genres.xls', 'application/vnd.ms-excel') }
      # Expect to import the file successfully
      it 'imports the file correctly' do
        expect(file.original_filename).to eq('genres.xls')
        expect(file.content_type).to eq('application/vnd.ms-excel')
        expect(file.size).to be > 0
      end
    end

    context "with invalid file" do
      # Initial data set up
      let(:file) { fixture_file_upload('invalid.xls', 'application/vnd.ms-excel') }
      # Expect to redirect to the genre index page
      it "redirects to genres path with alert notice" do
        post :import, params: { file: file }
        expect(response).to redirect_to(users_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "with no file selected" do
      # Expect to redirect to the genre index page with notice maessage
      it "redirects to genres path with alert notice" do
        post :import
        expect(response).to redirect_to(users_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  # Check for export action
  describe "GET #export" do

    # Expect to export the users to excel file
    it "exports users to Excel file" do
      user1 = User.create(name: "John Doe", email: "john@example.com", password: "password")
      user2 = User.create(name: "Jane Smith", email: "jane@example.com", password: "password")

      get :export

      expect(response.content_type).to eq("application/vnd.ms-excel")
      expect(response.headers["Content-Disposition"]).to include("attachment; filename=\"users.xls\"")
      expect(response.body).not_to be_empty  # Ensure that the response body is not empty
    end
  end

  # Check for delete image action
  describe 'DELETE #delete_image' do

    # Expect to delete the user image
    it 'deletes the user image and redirects with notice' do
      image = fixture_file_upload('m01.png', 'image/png')
      user1.image.attach(image)

      allow(User).to receive(:find).and_return(user1)

      expect(user1.image).to receive(:purge)

      delete :delete_image, params: { id: user1.id }

      expect(response).to redirect_to(edit_user_registration_path)
      expect(flash[:notice]).to eq('Image deleted successfully.')
    end

    # Expect to raise ActiveRecord error when an error occurs during image deletion
    it 'redirects with alert when an error occurs during image deletion' do
      image = fixture_file_upload('m01.png', 'image/png')
      user1.image.attach(image)
      allow(User).to receive(:find).and_return(user1)
      allow(user1.image).to receive(:purge).and_raise(StandardError, 'Test error message')

      expect(Rails.logger).to receive(:error).with(/Error occurred while deleting user image/)

      expect{
        delete :delete_image, params: { id: user1.id }
    }.to raise_error(ActiveRecord::Rollback)

      expect(response).to redirect_to(edit_user_registration_path)
      expect(flash[:alert]).to eq('Failed to delete user image. An error occurred while processing your request.')
    end
  end

  # Check for saved_movies action
  describe 'GET #saved_movies' do
    # Expect to assign user and saved movies
    it 'assigns user and saved movies' do
      # Sign in the user
      sign_in user1
      # Data set up
      genre1 = Genre.create(name: 'Action')
      movie = Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: tester,
        genre_ids: [genre1.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )

      # Create some movies saved by the user
      saved_movies = user1.saved_movies.map(&:movie)

      # Call the saved_movies action
      get :saved_movies, params: { id: user1.id }

      # Assert the assigns
      expect(assigns(:user)).to eq(user1)
      expect(assigns(:saved_movies)).to match_array(saved_movies)
    end

    # Expect to creates activity
    it 'creates an activity record for browsing saved movies' do
      # Sign in the user
      sign_in user1

      # Call the saved_movies action
      expect {
        get :saved_movies, params: { id: user1.id }
      }.to change { Activity.count }.by(1)

      # Check the activity record created
      activity = user1.activities.last
      expect(activity.action).to eq('Browsed Saved Movies Page')
    end
  end

  # Check for unsave action
  describe 'DELETE #unsave' do
    context 'when the movie is saved by the user' do
      it 'removes the movie from the saved list and redirects with notice' do
        # Sign in the user
        sign_in user1
        # Data set up
        genre1 = Genre.create(name: 'Action')
        movie = Movie.create(
          name: 'Sample Movie',
          review: 'This is a review of movie.',
          release_date: Date.today,
          duration: '1h 22m',
          trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
          user: tester,
          genre_ids: [genre1.id],
          image: fixture_file_upload('m01.png', 'image/png')
        )
        # Save the movie
        user1.saved_movies.create(movie: movie)

        # Call the saved_movies action
        get :saved_movies, params: { id: user1.id }
        # Call the unsave action
        delete :unsave, params: { id: movie.id }

        # Expectations
        expect(user1.saved_movies).not_to include(movie)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('Movie was removed from saved list successfully.')
      end
    end

    context 'when the movie is not saved by the user' do
      # Expect to rediect to the movie page with notice
      it 'redirects to the movie page with notice' do
        # Sign in the user
        sign_in user1
        genre1 = Genre.create(name: 'Action')
        movie = Movie.create(
          name: 'Sample Movie',
          review: 'This is a review of movie.',
          release_date: Date.today,
          duration: '1h 22m',
          trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
          user: tester,
          genre_ids: [genre1.id],
          image: fixture_file_upload('m01.png', 'image/png')
        )

        # Call the unsave action for a movie not saved by the user
        delete :unsave, params: { id: movie.id }

        # Expectations
        expect(response).to redirect_to(movie)
        expect(flash[:notice]).to eq('Movie is not in saved list')
      end
    end
  end

  # Check for dashboard action
  describe 'GET #dashboard' do
    context 'when admin is logged in' do
      # Expect to assign users and activites
      it 'assigns users and activities' do
        # Create non-admin users and activities
        users = [user1,user2]
        activities = user1.activities.create(action:"Logged In")

        # Call the dashboard action
        get :dashboard

        # Expectations
        expect(assigns(:users)).to match_array(users)
        expect(assigns(:activities)).to match_array(activities)
      end

      # Expect to render the dashboard template
      it 'renders the dashboard template' do
        # Call the dashboard action
        get :dashboard

        # Expectations
        expect(response).to render_template(:dashboard)
      end
    end

    context 'when non-admin user is logged in' do
      # Expect to redirect to the root path
      it 'redirects to root path' do
        sign_in user1
        # Call the dashboard action
        get :dashboard
        # Expectations
        expect(response).to redirect_to(root_path)
      end
    end
  end

  # Check for filter_by_user action
  describe 'GET #filter_by_user' do

    # Expect to assign activites for user
    it 'assigns activities for the specified user' do
      # Create some activities for the user
      activities = user1.activities.create(action:"Logged In")
      # Call the filter_by_user action
      get :filter_by_user, params: { user_id: user1.id }
      # Expectations
      expect(assigns(:user)).to eq(user1)
      expect(assigns(:activities)).to eq([activities])
    end

    # Expect to render the filter_by_user template
    it 'renders the filter_by_user template' do
      # Call the filter_by_user action
      get :filter_by_user, params: { user_id: user1.id }\
      # Expectations
      expect(response).to render_template(:filter_by_user)
    end
  end

  # Check for filter_by_user action
  describe 'GET #filter_by_time' do
    before do
      # Create activities for user1
      @activities_today = user1.activities.create(action:"Logged In", created_at: Time.zone.now)
      # Create activities for user2
      @activities = user1.activities.create(action:"Logged Out", created_at: Time.zone.now - 1.day)
    end

    # Expect to assign activites of today
    it 'assigns activities for today' do
      # Call the filter_by_time action with time_period set to "Today"
      get :filter_by_time, params: { time_period: "Today" }
      # Expectations
      expect(assigns(:period)).to eq("Today")
      expect(assigns(:activities)).to match_array([@activities_today])
    end

    # Expect to assign the activites for this week
    it 'assigns activities for this week' do
      # Call the filter_by_time action with time_period set to "This Week"
      get :filter_by_time, params: { time_period: "This Week" }
      # Expectations
      expect(assigns(:period)).to eq("This Week")
      expect(assigns(:activities)).to match_array(user1.activities)
    end

    # Expect to assign the activities for this week
    it 'assigns activities for this month' do
      # Call the filter_by_time action with time_period set to "This Month"
      get :filter_by_time, params: { time_period: "This Month" }
      # Expectations
      expect(assigns(:period)).to eq("This Month")
      expect(assigns(:activities)).to match_array(user1.activities)
    end
  end
end
