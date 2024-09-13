# lib/tasks/db.rake
require File.expand_path('../../../config/environment', __FILE__)
Dir["#{Rails.root}/app/models/*.rb"].each { |file| require file }

namespace :db do
  desc "Setup the database"
  task :setup do
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end

  desc "Reset the database"
  task :reset => :environment do
    puts "Resetting the database..."
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    puts "Database reset completed!"
  end

  desc "Rollback the last database migration"
    task :rollback => :environment do
      puts "Rolling back the last migration..."
      Rake::Task["db:rollback"].invoke
      puts "Rollback completed!"
  end

  desc "Backup the database"
  task :backup do
    puts "Backing up database..."
    # Define backup filename with timestamp
    backup_filename = "db_backup_#{Time.now.strftime('%Y%m%d_%H%M%S')}.sql"

    # Execute pg_dump command to create SQL dump file
    system("mysqldump -u root -p movie_review_development > #{backup_filename}")
    puts "Database backed up successfully!"
  end

  desc "Clean up the database by removing records older than 10 years"
  task :clean_old_data => :environment do
    puts "Cleaning up old data (10 years ago) from the database..."

    # Define the cutoff date as 10 years ago
    cutoff_date = 10.years.ago

    # Example: Remove old movies
    old_movies = Movie.where('created_at < ?', cutoff_date)
    old_movies_count = old_movies.count
    old_movies.destroy_all

    # Example: Remove old users with no associated data
    old_users = User.where('created_at < ? AND NOT EXISTS (SELECT 1 FROM users WHERE id = users.id)', cutoff_date)
    old_users_count = old_users.count
    old_users.destroy_all

    puts "Removed #{old_movies_count} old movies and #{old_users_count} old users from the database."
  end

  namespace :test do
    desc "Prepare the test database for movie review"
    task prepare: :environment do
      puts "Resetting the movie review test database..."

      # Execute shell commands to reset the test database
      system("RAILS_ENV=test bundle exec rake db:migrate:reset")
      system("RAILS_ENV=test bundle exec rake db:schema:load")

      puts "Movie review test database reset complete."
    end
  end

  desc "Clean up the database by removing activities older than 5 years"
  task :clean_old_activity_data => :environment do
    puts "Cleaning up old activity data (5 years ago) from the database..."

    # Define the cutoff date as 10 years ago
    cutoff_date = 5.years.ago

    # Example: Remove old movies
    old_data = Activity.where('created_at < ?', cutoff_date)
    old_data_count = old_data.count
    old_data.destroy_all

    puts "Removed #{old_data_count} old activities from the database."
  end

end
