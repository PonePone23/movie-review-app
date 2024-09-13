require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

# Schedule task to run every minute
scheduler.cron '0 0 1 1 *' do
  puts "Executing task every year..."
  Year.create(year: Date.current.year)
end
