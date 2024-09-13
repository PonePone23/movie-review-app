# lib/tasks/delete_recently.rake
namespace :history do
  desc "Delete old history entries"
  task delete_old: :environment do
    History.where('created_at < ?', 1.minute.ago).destroy_all
    #History.where('created_at < ?', 1.day.ago).destroy_all
    puts "Old history entries deleted."
  end
end
