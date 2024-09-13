# spec/models/reply_spec.rb
require 'rails_helper'

RSpec.describe Reply, type: :model do
  #Test cases for validations
  describe 'validations' do
    # Expect Reply not to be valid without content
    it 'requires content to be present' do
      reply = Reply.new(content: nil)
      reply.valid?
      expect(reply.errors[:content]).to include("can't be blank")
    end
  end

  # Test cases for associations
  describe 'associations' do
    # Test case for association Reply and User
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    # Test case for association Reply and Discussion
    it 'belongs to a discussion' do
      association = described_class.reflect_on_association(:discussion)
      expect(association.macro).to eq :belongs_to
    end
  end
end
