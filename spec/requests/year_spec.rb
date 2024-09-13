# spec/requests/year_spec.rb
require 'rails_helper'

RSpec.describe YearsController, type: :controller do
  include Devise::Test::ControllerHelpers

  # Intial data set up
  let(:year) {Year.create(year:2000)}
  let(:genre1) { Genre.create(name: 'Action') }
  let(:genre2) { Genre.create(name: 'Comedy') }
  let(:admin){ User.create(email:"admin@admin.com",password:"123123",admin:1,name:"admin") }
  let(:user){ User.create(email:"user@user.com",password:"123123",name:"admin") }
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

  # Test for index page
  describe 'GET #index' do
    #testing index has successful response
    it 'returns a successful response' do
      sign_in user
      get :index
      expect(response).to be_successful
    end

    # Testing index has assigned all years
    it 'assigns all years in index' do
      sign_in user
      # Create 10 years from 2000 to 2009
      (2000..2009).each do |year|
        Year.create(year: year)
      end

      # Ensure that the assigned years match the expected order
      get :index  # Replace 'index' with the appropriate action name
      expected_years = Year.order(year: :desc).pluck(:year)
      obtained_years = assigns(:years).map(&:year)
      expect(obtained_years).to eq(expected_years)
    end

    # Testing pagination
    it 'assigns year according to the page' do
      sign_in user
      years = (1..20).map { |n| Year.create(year: 2000 + n) }
      get :index, params: { page: 1 }
      assigned_years = assigns(:years)
      expect(assigned_years[0].year).to eq("2020")
      get :index, params: { page: 2 }
      assigned_years = assigns(:years)
      expect(assigned_years[0].year).to eq("2010")
    end
  end

  # Testing new
  describe 'GET #new' do
    # Testing new has successful response
    it 'returns a successful response' do
      sign_in admin
      get :new
      expect(response).to be_successful
    end

    # Testing new has assigned a new year
    it 'new assign year' do
      sign_in admin
      get :new
      expect(assigns(:year)).to be_a_new(Year)
    end
  end

  # Testing edit
  describe 'GET #edit' do
    # Testing edit has a successful response
    it 'returns a successful response' do
      sign_in admin
      get :edit, params: { id: year.id }
      expect(response).to be_successful
    end

    # Testing edited year has assigned the year
    it 'assigns the edited year' do
      sign_in admin
      get :edit, params: { id: year.id }
      expect(assigns(:year)).to eq(year)
    end
  end

  # Testing create a year
  describe 'POST #create' do
   # With valid parameter
   context 'with valid parameters' do
      # Create a year with valid params
      it 'creates a new year' do
        sign_in admin
        year_params = {year:2000}
        expect {
          post :create, params: { year: year_params }
        }.to change(Year, :count).by(1)
      end

      # Testing redirect the created year
      it 'redirects to the created year' do
        sign_in admin
        year_params = {year:2000}
        post :create, params: { year: year_params }
        expect(response).to redirect_to(years_path)
      end
   end

   # Testing with invalid params
   context 'with invalid parameters' do
    # Should not create a year
    it 'not create a new year' do
      sign_in admin
      invalid_params = { year: '' }
      expect {
        post :create, params: { year: invalid_params }
      }.not_to change(Year, :count)
    end

    # Testing render to new with invalid param
    it 'renders the new template if the parameter is invalid' do
      sign_in admin
      invalid_params = { name: ' ' }
      post :create, params: { year: invalid_params }
      expect(response).to render_template(:new)
    end
   end

   # Expect to raise ActiveRecord error
   it "raises ActiveRecord::Rollback and redirects with error alert" do
     allow_any_instance_of(Year).to receive(:save).and_raise(StandardError, "Test error message")
     expect {
       post :create, params:  { year: { year: 2000 }}
     }.to raise_error(ActiveRecord::Rollback)

     expect(response).to redirect_to(years_path)
     expect(flash[:alert]).to eq("Error occurred: Test error message")
   end
  end

  # Testing update
  describe "Post #update" do
    # With valid params
    context "with valid params" do
      # Update the new year
      it "update the new year" do
        sign_in admin
        new_year = "2001"
        patch :update, params: { id:year.id, year: { year: new_year } }
        year.reload
        expect(year.year).to eq(new_year)
        expect(response).to redirect_to(years_path)
      end
    end

    # Update the year with invalid params
    context "with invalid params" do
      # Should not update to the new year when blank
      it "does not update the year" do
        sign_in admin
        patch :update, params: { id: year.id, year: { year: "" } }
        year.reload
        expect(year.year).to_not eq("")
      end

      # Render to edit and not update
      it 're-renders the edit template with status :unprocessable_entity' do
        sign_in admin
        patch :update, params: {id: year.id, year: { year: "" } }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
    end

    # Expect to raise ActiveRecord error
    it "raises ActiveRecord::Rollback and redirects with error alert" do
      allow_any_instance_of(Year).to receive(:update).and_raise(StandardError, "Test error message")
      expect {
        patch :update, params: { id:year.id, year: { year: 2001 } }
      }.to raise_error(ActiveRecord::Rollback)

      expect(response).to redirect_to(years_path)
      expect(flash[:alert]).to eq("Error occurred: Test error message")
    end
  end

  # Testing delete a year
  describe 'DELETE #destroy' do
    it 'destroys the requested year' do
      sign_in admin
      year=Year.create(year:2000)
      expect {
       delete :destroy, params: { id: year.id }
       }.to change(Year, :count).by(-1)
       expect(response).to redirect_to(years_path)
    end
    # Year does not exist
    context "when year does not exist" do
      it "redirects with alert when year is not found" do
        delete :destroy, params: { id: -1 } # Assuming -1 is an invalid ID
        expect(response).to redirect_to(years_path)
        expect(flash[:alert]).to eq("Year not found.")
      end
    end
    context "when an error occurs during destruction" do
      # Expect to raise ActiveRecord error
      it "handles exceptions and raises ActiveRecord::Rollback" do
        allow_any_instance_of(Year).to receive(:destroy!).and_raise(StandardError, "Test error message")

        expect {
          delete :destroy, params: { id: year.id }
        }.to raise_error(ActiveRecord::Rollback)
      end
    end
  end

  # Testing search method
  describe 'POST #search' do
    # When search parameter is blank
    context 'when search parameter is blank' do
      # Expect to rediret to year index page
      it 'redirects to years_path with alert message' do
        sign_in user
        post :search, params: { search: '' }
        expect(response).to redirect_to(years_path)
        expect(flash[:alert]).to eq('Type Year to search')
      end
    end

    # When search parameter is present
    context 'when search parameter is present' do
      # Expect to show years that match the search parameter
      it 'assigns @results with matching years' do
        sign_in user
        year1 = Year.create(year: 2024)
        post :search, params: { search: '2024' }
        expect(assigns(:results)).to include(year1)
      end
    end
  end

  # Testing import method
  describe 'POST #import' do
    # Upload file is vlaid
    context 'when a valid file is uploaded' do
      # Upload file valid_years.xls and it has to import
      it 'imports years from the uploaded file' do
        sign_in admin
        valid_file = fixture_file_upload('valid_years.xls', 'application/vnd.ms-excel')
        before_import_count = Year.count
        post :import, params: { file: valid_file }
        after_import_count = Year.count
        imported_years = after_import_count - before_import_count
        expect(response).to redirect_to(years_path)
      end
    end

    # When file format is not valid
    context 'when the file format is invalid' do
      # Alert a message
      it 'redirects with an alert message' do
        sign_in admin
        invalid_file = fixture_file_upload('invalid.xlsx', 'application/vnd.ms-excel')
        post :import, params: { file: invalid_file }
        expect(response).to redirect_to(years_path)
        expect(flash[:alert]).to be_present
      end
    end

    # No file is selected
    context 'when no file is selected for import' do
      # Alert a message
      it 'redirects with an alert message' do
        sign_in admin
        post :import
        expect(response).to redirect_to(years_path)
        expect(flash[:alert]).to include('No file selected for import')
      end
    end
  end

  # Testing an export method
  describe 'GET #export' do
    # Got a .xls file
    it 'sends a downloadable spreadsheet' do
      sign_in admin
      allow(Year).to receive(:all).and_return([Year.new(year: 2000), Year.new(year: 2001)])
      get :export
      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq('application/vnd.ms-excel')
      expect(response.headers['Content-Disposition']).to match(/released_years\.xls/)
      end
    end
  end

  # Test for show method
  describe "Get #show" do
    # Test for assigning @years with all years ordered by year descending
    it "assigns @years with all years ordered by year descending" do
      get :show, params: { id: year.id }
      expect(assigns(:years)).to eq(Year.order(year: :desc).all)
    end

    # Test for assigning @genres with all genres ordered by name
    it "assigns @genres with all genres ordered by name" do
      get :show, params: { id: year.id }
      expect(assigns(:genres)).to eq(Genre.order(:name).all)
    end

    # Test for assigning @year with the specified year
    it "assigns @year with the specified year" do
      get :show, params: { id: year.id }
      expect(assigns(:year)).to eq(year)
    end

    # Test for assigning @result with movies released in the specified year
    # it "assigns @result with movies released in the specified year" do
    #  get :show, params: { id: year.id }
    #  expect(assigns(:result)).to eq([movie])
    #end
    # Context for when a user is logged in
    context "when a user is logged in" do
      before do
        sign_in user
      end

      # Test for creating an activity for the current user
      it "creates an activity for the current user" do
        expect {
          get :show, params: { id: year.id }
        }.to change { Activity.count }.by(1)
        expect(user.activities.last.action).to eq("Filtered movies with year '#{year.year}'")
      end
    end

    # Context for when no user is logged in
    context "when no user is logged in" do
      # Test for not creating any activity
      it "does not create any activity" do
        expect {
          get :show, params: { id: year.id }
        }.not_to change { Activity.count }
      end
    end
  end

  # Test for save method
  describe "Post #save " do
    context "when the user hasn't saved the movie before" do
      before { sign_in user }

      # Expect to redirect to referrer page
      it "associates the movie with the current user and redirects back with a notice" do
        request.env["HTTP_REFERER"] = "/some/url"
        post :save, params: { id: movie.id }
        expect(user.movies).to include(movie)
        expect(response).to redirect_to("/some/url")
        expect(flash[:notice]).to eq("Movie saved successfully.")
      end
    end

    context "when the user has already saved the movie" do
      before do
        sign_in user
        user.movies << movie
      end

      # Expect not to save the movie again
      it "does not duplicate the association and redirects back with a notice" do
        # Stub request.referrer to simulate a referrer URL
        request.env["HTTP_REFERER"] = "/some/url"
        post :save, params: { id: movie.id }
        expect(user.movies.count).to eq(1) # Ensure the association is not duplicated
        expect(response).to redirect_to("/some/url")
        expect(flash[:notice]).to eq("Movie saved successfully.")
      end
    end
  end

  # Test for unsave method
  describe "DELETE #unsave" do
    before {sign_in user}
    context "when the movie is already saved by the current user" do
      before do
        user.saved_movies.create(movie: movie)
      end

      # Expect to remove the movie from the saved list
      it "removes the movie from the saved list and redirects back with a notice" do
        request.env["HTTP_REFERER"] = "/some/url"
        delete :unsave, params: { id: movie.id }
        expect(user.reload.saved_movies.count).to eq(0) # Ensure the movie is removed from the saved list
        expect(response).to redirect_to("/some/url")
        expect(flash[:notice]).to eq("Movie was removed from saved list successfully.")
      end
    end
    context "when the movie is not saved by the current user" do
      # Expect to redierct to the movie page
      it "redirects to the movie page with a notice" do
        movie_id = movie.id
        delete :unsave, params: { id: movie_id }
        expect(response).to redirect_to(movie_path(movie_id))
        expect(flash[:notice]).to eq("Movie is not in saved list")
      end
    end
  end
end
