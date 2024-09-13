# spec/models/reaction_spec.rb
require 'rails_helper'

RSpec.describe Reaction, type: :model do
  after(:each) do
    Discussion.destroy_all
    Reaction.destroy_all
    User.destroy_all
    # Add cleanup for other relevant models if needed
  end

  # Set up initial database
  let(:user) { User.create(name: 'John Doe', email: 'john@example.com', password: 'password') }
  let(:discussion) { Discussion.create(user_id: user.id , content: 'Discussion content') }
  let(:reaction) { Reaction.new(user: user, discussion: discussion) }

  # Test cases for associations
  describe 'associations' do
    # Test case for associaton Reaction and User
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    # Test for association Reaction and Discussion
    it 'belongs to a discussion' do
      association = described_class.reflect_on_association(:discussion)
      expect(association.macro).to eq :belongs_to
    end

  end

  # Test cases for showing user name
  describe '#user_name' do
    context 'when user is present' do
      # Expect to return the name of the associated user
      it 'returns the name of the associated user' do
        expect(reaction.user_name).to eq('John Doe')
      end
    end

    context 'when user is not present' do
      # Expect to return nil if user do not present
      it 'returns nil' do
        reaction.user = nil
        expect(reaction.user_name).to be_nil
      end
    end
  end
end
