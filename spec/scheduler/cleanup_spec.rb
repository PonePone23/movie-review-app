# spec/initializers/cleanup_spec.rb
require 'rails_helper'

# Test cases for cleanup.rb
RSpec.describe 'cleanup.rb initializer' do
  # Test cases for seheduler setup
  describe 'scheduler setup' do
    # Expect to creaate scheduler
    it 'creates a scheduler' do
      expect { initialize_scheduler }.not_to raise_error
    end
  end

  private
  # method to initialize the scheduler
  def initialize_scheduler
    # load the cleanup.rb from config/initializers
    load Rails.root.join('config', 'initializers', 'cleanup.rb')
  end
end
