# spec/initializers/recently_visited_spec.rb
require 'rails_helper'

# Test cases for recently_visited.rb
RSpec.describe 'recently_visited.rb initializer' do
  # Test case of setting up scheduler
  describe 'scheduler setup' do
    # Expect to create a scheduler
    it 'creates a scheduler' do
      expect { initialize_scheduler }.not_to raise_error
    end
  end

  private

  # Method to create a scheduler
  def initialize_scheduler
    # Load recently_visted.rb from config/initialzers
    load Rails.root.join('config', 'initializers', 'recently_visited.rb')
  end
end
