$PROJECT_ROOT = File.dirname(__FILE__)

desc 'Start IRB and load the database'
task irb: [:require] do
  require 'irb'
  ARGV.clear
  IRB.start
end

task :require do
  require File.join($PROJECT_ROOT, 'db.rb')
end

task :dump_activities => [:require] do
  File.open('activities.csv', 'w') do |f|
  	Activity.each{|a| f.puts("#{a.user_id}, #{a.name}, #{a.steps}, #{a.date}")}
  end 
end

task :archive_activities => [:require] do
  users = User.all

  end_of_last_month = Date.today - Date.today.mday
  beginning_of_last_month = end_of_last_month - end_of_last_month.mday + 1

  deleted = 0

  Activity.all(:date.lt => beginning_of_last_month)
    .group_by{|a| {user_id: a.user_id, month: a.date - a.date.day + 1}}
    .each do |a|
      user_id = a[0][:user_id]
      month = a[0][:month]
      steps = a[1].inject(0){|m, o| m + o.steps}
      activities = a[1]
      user = users.select{|u| u.user_id == user_id}.first

      month_activity = Activity.new
	  month_activity.steps = steps
	  month_activity.date = month 
	  month_activity.user_id = user_id
	  month_activity.name = user.name
	  month_activity.team = user.team 
	  month_activity.save

      activities.each{|x| x.destroy}

      deleted += activities.count
    end

  puts "Archived #{deleted} records"
end

task :activity_count => [:require] do
  puts Activity.all.count
end

task :set_db do
  cmd = "export DATABASE_URL=`heroku config | grep DATABASE_URL | cut -c30-` && ENV | grep DATABASE_URL"
  x = `#{cmd}`
  puts x
end