# spec/initializers/add_year_spec.rb
require 'rails_helper'

# Test case for add_year.rb
RSpec.describe 'add_year.rb initializer' do
  # Test case for setting up scheduler
  describe 'scheduler setup' do
    # Expect to create a scheduler
    it 'creates a scheduler' do
      expect { initialize_scheduler }.not_to raise_error
    end

    # Expect to run this scheduler every year
    it 'schedules task to run every year' do
      allow($stdout).to receive(:puts)
      expect_any_instance_of(Rufus::Scheduler).to receive(:cron).with('0 0 1 1 *').and_yield
      expect(Year).to receive(:create).with(year: Date.current.year)
      initialize_scheduler
    end
  end
  private

  # Method to initialize the scheduler
  def initialize_scheduler
    # Load add_year.rb from config/initilizers
    load Rails.root.join('config/initializers/add_year.rb')
  end
end
