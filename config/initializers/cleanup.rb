#config/initializers/cleanup.rb
require 'rufus-scheduler'

# Create a new Rufus scheduler instance
scheduler = Rufus::Scheduler.new

# Define the scheduled task
scheduler.every '24h' do
  # Output a message indicating that the task is running
  puts "Running cleanup:temporary_files_and_logs task at #{Time.now}"
  # Execute the rake task directly
  system('bundle exec rake cleanup:temporary_files_and_logs')
end
