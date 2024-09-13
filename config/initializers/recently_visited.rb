# config/initializers/scheduler.rb

require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

##scheduler.every '1m' do
##  # Task to print text
##  File.open(Rails.root.join('log', 'print_text.log'), 'a') do |f|
##    f.puts "Hello, Testing! #{Time.now}"
##    f.flush
##    sleep 30
##  end
##end
#
#scheduler.every '1m' do
# # Task to delete old history records
#  if History.exists?
#    History.delete_all
#    puts "Old history entries deleted."
#  else
#    puts "No history entries to delete."
#  end
#end

scheduler.at '00:00:00' do
  # Delete history records older than one day
  History.where('created_at < ?', 1.day.ago).delete_all
  puts "History records older than one day deleted."
end
