# lib/tasks/cleanup.rake

namespace :cleanup do
  desc "Clean up temporary files and logs"
  task :temporary_files_and_logs => :environment do
    puts "Cleaning up temporary files..."
    # Replace '/path/to/temporary/files' with the actual path to your temporary files directory
    Dir.glob('../../tmp/*').each do |file|
      File.delete(file) if File.file?(file)
    end
    puts "Temporary files cleaned up."

    puts "Cleaning up logs..."
    # Replace '/path/to/logs' with the actual path to your logs directory
    Dir.glob('../../log/*.log').each do |file|
      File.delete(file) if File.file?(file)
    end
    puts "Logs cleaned up."
  end
end
