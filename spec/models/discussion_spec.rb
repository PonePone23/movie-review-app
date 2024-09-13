# spec/models/discussion_spec.rb
require 'rails_helper'

RSpec.describe Discussion, type: :model do
  # Test cases for associatons
  describe 'associations' do
    # Test for associations Discussion and User
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    # Test for association Discussion with Reaction
    it 'has many reactions with dependent destroy' do
      association = described_class.reflect_on_association(:reactions)
      expect(association.macro).to eq :has_many
      expect(association.options).to include(dependent: :destroy)
    end

    # Test for association Discussion and Reply
    it 'has many replies with dependent destroy' do
      association = described_class.reflect_on_association(:replies)
      expect(association.macro).to eq :has_many
      expect(association.options).to include(dependent: :destroy)
    end
  end
end
