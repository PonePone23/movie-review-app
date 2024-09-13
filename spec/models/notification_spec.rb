# spec/models/notification_spec.rb
require 'rails_helper'

RSpec.describe Notification, type: :model do
  # Test cases for associations
  describe 'associations' do
    # Expect the associations between Notification and Recipient to have belongs to
    it 'belongs to recipient' do
      association = described_class.reflect_on_association(:recipient)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:class_name]).to eq 'User'
    end

    # Expect the association between the Notification and Actor to have belongs to
    it 'belongs to actor' do
      association = described_class.reflect_on_association(:actor)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:class_name]).to eq 'User'
    end

    # Expect the association between the Notification and Notifiable to have belongs to
    it 'belongs to notifiable' do
      association = described_class.reflect_on_association(:notifiable)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:polymorphic]).to be true
    end
  end
end
