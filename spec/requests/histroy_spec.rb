# spec/requests/histroy_spec.rb
require 'rails_helper'

RSpec.describe HistoriesController, type: :controller do
  include Devise::Test::ControllerHelpers
  after(:each) do
    Movie.destroy_all
    Genre.destroy_all
    User.destroy_all
    # Add cleanup for other relevant models if needed
  end
    # Initial data set up
    let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password', admin:1) }
    let(:genre) { Genre.create(name: 'Action') }
    let(:movie) do
      Movie.create(
        name: 'Sample Movie',
        review: 'This is a review of the movie.',
        release_date: Date.today,
        duration: '1h 22m',
        trailer_url: "https://www.youtube.com/watch?v=1VIZ89FEjYI&t=1s",
        user: user,
        genre_ids: [genre.id],
        image: fixture_file_upload('m01.png', 'image/png')
      )
    end
    let(:history) { History.create(user: user, movie: movie) }

  before do
    sign_in user
  end

  # Test cases for deleting the histroy
  describe 'DELETE #destroy' do
    # Expect to destroy the histroy
    it 'destroys the requested history' do
      request.env["HTTP_REFERER"] = "/some/url"
      delete :destroy, params: { id: history.id }
      expect(response).to redirect_to("/some/url")
      expect(flash[:notice]).to eq('Movie removed from history')
    end
  end

  # Test cases for deleting all recent histroies fo user
  describe 'DELETE #delete_all' do
    # Expect to delete all histories
    it 'destroys all histories' do
      request.env["HTTP_REFERER"] = "/some/url"
      delete :delete_all
      expect(response).to redirect_to("/some/url")
      expect(flash[:notice]).to eq('All histories deleted')
    end
  end

  # Test cases for setting up the histroy
  describe '#set_history' do

    before(:each) do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'when history is found' do
      it 'assigns the requested history to @history' do
        # Stubbing the find method to return the history object
        allow(user.histories).to receive(:find).with(history.id.to_i).and_return(history)

        # Simulating a request with a valid history ID
        controller.params[:id] = history.id
        controller.send(:set_history)

        # Verifying that @history is correctly assigned
        expect(assigns(:history)).to eq(history)
      end
    end

    # Expect to raise ActiveRecord error when history is not found
    it 'raises ActiveRecord::RecordNotFound when history is not found' do
      allow(user.histories).to receive(:find).and_raise(ActiveRecord::RecordNotFound)

      controller.params[:id] = 'invalid_id'

      expect {
        controller.send(:set_history)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
