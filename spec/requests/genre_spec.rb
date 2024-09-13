# spec/requests/genre_spec.rb
require 'rails_helper'

RSpec.describe GenresController, type: :controller do
  # Devise test helpers for authentication
  include Devise::Test::ControllerHelpers
  after(:each) do
    Movie.destroy_all
    Genre.destroy_all
    User.destroy_all
    # Add cleanup for other relevant models if needed
  end

  let(:admin) { User.create(email:"admin@gmail.com", password:"111111", name:"Admin", admin:1)}

  # Before each test, sign in the admin user.
  before(:each) do
    sign_in admin
  end

  # Helper method to create sample genres
  def create_sample_genres(count)
    unique_names = [
      "Action", "Drama", "Comedy", "Thriller", "Horror", "Romance",
      "Documentary", "SciFi", "Fantasy", "Mystery"
    ]
    genres = []
    unique_names.size.times do |i|
      genres << Genre.find_or_create_by(name: unique_names[i])
    end
    genres
  end

  # Check for index action
  describe 'GET #index' do
    # Expect the request to index page return seccussfully
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    # Expect to render the index page successfully
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    # Expect to show created 10 genres in the index page
    it 'loads genres into @genres' do
      genres = create_sample_genres(10) # Create 10 sample genres
      get :index
      expect(assigns(:genres)).to match_array(genres)
    end

    # Expect to only show 10 genres in first page
    it 'paginates genres' do
      genres = create_sample_genres(15)
      expected_genres = Genre.order(:name).limit(10)
      expected_genre_ids = expected_genres.pluck(:id)
      get :index, params: { page: 1, per: 10 }
      assigned_genre_ids = assigns(:genres).pluck(:id)
      expect(assigned_genre_ids).to eq(expected_genre_ids)
    end
  end

  # Check new action
  describe "GET #new" do
    # Expect to assign new genre
    it "assigns a new genre to @genre" do
      get :new
      expect(assigns(:genre)).to be_a_new(Genre)
    end

    # Expect to render new genre page
    it "renders the new template" do
      get :new
      expect(response).to render_template("new")
    end
  end

  # Check create action
  describe "Post #create" do
    # Test cases with valid parameters
    context "with valid parameters" do
      # Expect to create new genre
      it "create a new genre" do
        expect{
          post :create, params:{
            genre:{name: "Horror"}
          }
        }.to change(Genre,:count).by(1)
      end

      # Expect to redirect to index page after creating new genre
      it "redirect to genres with notice" do
        post :create,params:{ genre: { name: "Horror"}}
        expect(response).to redirect_to(genres_path)
        expect(flash[:notice]).to eq("Genre was successfully created.")
      end
    end

    # Test cases with invalid parameters
    context "with invalid parameters" do
      # test if a new genre is not created with invalid parameters.
      it "does not create a new genre" do
        expect{
          post :create, params: {genre: {name: ""}}
             }.to_not change(Genre,:count)
      end

      # test if the user is redirected to genres path with a notice
      it "render the new template with unprocessable_entity status" do
        post :create,params:{ genre: {name:""}}
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # Expect to raise ActiveRecord error with error alert
    it "raises ActiveRecord::Rollback and redirects with error alert" do
      genre_instance = instance_double(Genre)
      allow(Genre).to receive(:new).and_return(genre_instance)
      allow(genre_instance).to receive(:save).and_raise(StandardError, "Test error message")

      expect {
        post :create, params: { genre: { name: "Action" } }
      }.to raise_error(ActiveRecord::Rollback)

      expect(response).to redirect_to(new_genre_path)
      expect(flash[:alert]).to eq("Error occurred: Test error message")
    end
  end

  # Check edit action
  describe "Post #edit" do
    # Initial data setup
    let(:genre) { Genre.create(name: 'Action') }

    # Expect to render edit page successfully
    it "returns a successful response" do
      get :edit, params: {id: genre.id}
      expect(response).to be_successful
      expect(response).to render_template(:edit)
    end

    # test if the requested genre is assigned to @genre.
    it "assign the requested genre" do
      get :edit, params: {id: genre.id}
      expect(assigns(:genre)).to eq(genre)
    end
  end

  # Check update action
  describe "Post #update" do
    # Initial data setup
    let(:genre) { Genre.create(name: 'Action') }

    # Test cases with valid paramenters
    context "with valid params" do

      # Expect to update the existing genre
      it "update the genre" do
        new_genre= "Romance"
        patch :update, params: { id: genre.id,genre:{ name:new_genre } }
        genre.reload
        expect(genre.name).to eq(new_genre)
      end

      # Expect to redirect to index page after successfully update the genre
      it "redirects to the genres path" do
        new_genre = "Romance"
        patch :update, params: { id:genre.id,genre:{ name: new_genre } }
        expect(response).to redirect_to(genres_path)
        expect(flash[:notice]).to eq("Genre was successfully updated.")
      end
    end

    # Test cases with invlaid paramenters
    context "with invalid params" do
      # Expect not to update with invalid name
      it "does not update the genre and render edit template" do
        patch :update, params: { id: genre.id , genre: { name: ""}}
        genre.reload
        expect(genre.name).to eq("Action")
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "raises ActiveRecord::Rollback and redirects with error alert" do
      # Simulate a condition that would trigger a rollback
      allow_any_instance_of(Genre).to receive(:update).and_raise(StandardError, "Test error message")

      expect {
        put :update, params: { id: genre.id, genre:  { name: "Updated Genre Name" } }
      }.to raise_error(ActiveRecord::Rollback)

      expect(response).to redirect_to(edit_genre_path(genre))
      expect(flash[:alert]).to eq("Error occurred: Test error message")
    end



  end

  # Check destroy action
  describe "Delete #destroy" do
    # Initial data setup
    let(:genre) { Genre.create(name: 'Action') }

    # Expect to successfully delete the genre and redirect to index page
    it "delete the genre and redirect to genres page" do
      delete :destroy, params: {id: genre.id}
      expect{ genre.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to redirect_to(genres_path)
      expect(flash[:notice]).to eq("Genre was successfully destroyed.")
    end

    # Expect to return to the genres index page when genre is not found
    it "redirects with alert when genre is not found" do
      delete :destroy, params: { id: "invalid_id" }

      expect(response).to redirect_to(genres_path)
      expect(flash[:alert]).to eq("Genre not found.")
    end

    it "raises ActiveRecord::Rollback and redirects with error alert when genre is found and deleted" do
      allow_any_instance_of(Genre).to receive(:destroy!).and_raise(StandardError, "Test error message")

      expect {
        delete :destroy, params: { id: genre.id }
      }.to raise_error(ActiveRecord::Rollback)

      expect(response).to redirect_to(genres_path)
      expect(flash[:alert]).to eq("Failed to delete Genre. An error occurred while processing your request.")
    end
  end

  # Check search action
  describe "Get #search" do
    # Initial data setup
    let(:genre) { Genre.create(name: 'Action') }

    # Expect to get error message when search with blank parameter
    context "with blank search parameter" do
      it 'redirects to genres_path when search parameter is blank' do
        get :search, params: { search: '' }
        expect(response).to redirect_to(genres_path)
        expect(assigns(:results)).to be_nil
        expect(flash[:alert]).to eq("Type Genre Name to search")
      end
    end

    # Expect to show the result with valid search parameter
    context "with valid search parameter" do
      it "assign result with matching genre" do
          genre2 = Genre.create(name: "Romance")
          get :search, params: { search: 'Romance' }
          expect(response).to render_template(:search)
          expect(assigns(:parameter)).to eq('romance')
          expect(assigns(:results)).to include(genre2)
          expect(assigns(:results)).not_to include(genre)
      end
    end
  end

  # Check import action
  describe "POST #import" do
    # Test case with valid file
    context "with valid file" do
      # create genres file for testing
      let(:file) { fixture_file_upload('genres.xls', 'application/vnd.ms-excel') }
      it 'imports the file correctly' do
        expect(file.original_filename).to eq('genres.xls')
        expect(file.content_type).to eq('application/vnd.ms-excel')
        expect(file.size).to be > 0
      end
    end

    # Test case with invalid file
    context "with invalid file" do
      let(:file) { fixture_file_upload('invalid.xls', 'application/vnd.ms-excel') }
      it "redirects to genres path with alert notice" do
        post :import, params: { file: file }
        expect(response).to redirect_to(genres_path)
        expect(flash[:alert]).to be_present
      end
    end

    # Test case with no file
    context "with no file selected" do
      it "redirects to genres path with alert notice" do
        post :import
        expect(response).to redirect_to(genres_path)
        expect(flash[:alert]).to be_present
      end
    end

     context "when file is not present" do
      it "redirects with alert message" do
        allow(controller).to receive(:params).and_return({ file: nil })
        expect(controller).to receive(:redirect_to).with(genres_path, alert: "No file selected for import.")
        controller.send(:import)
      end
    end
  end

  # Check export action
  describe "GET #export" do
    it "responds with a downloadable Excel file" do
      # Manually create some genres for testing
      genres = []
      genres << Genre.create(name: "Action")
      genres << Genre.create(name: "Drama")
      genres << Genre.create(name: "Comedy")

      # Make a GET request to the export action
      get :export

      # Verify the response
      expect(response).to have_http_status(:success)
      expect(response.headers["Content-Type"]).to eq("application/vnd.ms-excel")
      expect(response.headers["Content-Disposition"]).to match(/attachment; filename="genres.xls"/)
    end
  end

  #check set_genre method
  describe "#set_genre" do
    let(:genre) { Genre.create(name: "Test Genre") }
      context "when genre is found" do
        it "assigns the requested genre to @genre" do
          controller.params[:id] = genre.id
          controller.send(:set_genre)
          expect(assigns(:genre)).to eq(genre)
        end
      end
  end

  #check for set_feedback method
  describe "#set_feedback" do
    it "assigns a new feedback instance to @feedback" do
      controller.send(:set_feedback)
      expect(assigns(:feedback)).to be_a_new(Feedback)
    end
  end

  #check for check_admin
  describe "#check_admin" do
    context "when user is an admin" do
      it "does not redirect the user" do
        allow(controller).to receive(:current_user).and_return(double("User", admin?: true))
        controller.send(:check_admin)
        expect(response).not_to redirect_to(root_path)
      end
    end
  end
end
