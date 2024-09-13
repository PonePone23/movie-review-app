#spec/modles/activity_spec.rb
require 'rails_helper'

RSpec.describe Activity, type: :model do
  # Test assiciations of Activity model
  describe 'associations' do
    # Expect association between Activity and User to be belongs_to
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end
  end
end
