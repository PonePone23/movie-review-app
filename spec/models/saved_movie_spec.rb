require 'rails_helper'

RSpec.describe SavedMovie, type: :model do
  # Test cases for associations
  describe 'associations' do
    # Expect the association between Saved_Movies and User to have belongs_to
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    # Expect the association between Saved_Movie and Movie to have belongs to
    it 'belongs to a movie' do
      association = described_class.reflect_on_association(:movie)
      expect(association.macro).to eq(:belongs_to)
    end
  end
end
