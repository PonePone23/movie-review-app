#spec/models/history_spec.rb
require 'rails_helper'

RSpec.describe History, type: :model do
  # Test cases for assiciations
  describe "associations" do
    # Expect the assocaitions between the History and User to be belong to
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:class_name]).to eq 'User'
    end

    # Expect the association between the History and User to have belong to
    it 'belongs to movie' do
      association = described_class.reflect_on_association(:movie)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:class_name]).to eq 'Movie'
    end
  end
end
