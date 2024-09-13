# spec/models/feedback_spec.rb
require 'rails_helper'

RSpec.describe Feedback, type: :model do
  # Test create operation for Feedback Model
  describe 'create feedback' do
    # Expect feedback to be valid
    it 'creates a new movie' do
      feedback = Feedback.create(name: 'John Doe', email: 'john@example.com', message: 'This is sample message.')
      expect(feedback).to be_valid
    end
  end

  # Test validations of Feedback Model
  describe "validations" do
    # Expect feedback to be invalid without a name
    it 'validates presence of name' do
      feedback = Feedback.create(name: '', email: 'john@example.com', message: 'This is sample message.')
      expect(feedback).not_to be_valid
      expect(feedback.errors[:name]).to include("can't be blank")
    end

    # Expect feedback to be invalid without email
    it 'validates presence of email' do
      feedback = Feedback.create(name: 'John Doe', email: '', message: 'This is sample message.')
      expect(feedback).not_to be_valid
      expect(feedback.errors[:email]).to include("can't be blank")
    end

    # Expect feedback to be invalid without feedback message
    it 'validates presence of name' do
      feedback = Feedback.create(name: 'John Doe', email: '', message: '')
      expect(feedback).not_to be_valid
      expect(feedback.errors[:message]).to include("can't be blank")
    end

    # Test case with valid email
    context 'when email is valid' do
      # Expect feedback to be valid with valid email
      it 'is valid' do
        feedback = Feedback.create(name: 'John Doe', email: 'john@example.com', message: 'This is sample message.')
        expect(feedback).to be_valid
      end
    end

    # Test case for invalid email
    context 'when email is invalid' do
      # Expect feedbacl not to be valid with invalid email
      it 'is invalid' do
        feedback = Feedback.create(name: 'John Doe', email: 'johngmail.com', message: 'This is sample message.')
        expect(feedback).not_to be_valid
      end
    end
  end
end
