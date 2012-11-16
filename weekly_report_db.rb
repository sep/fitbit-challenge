require 'rubygems'
require 'bundler/setup'
require 'date'
require 'mail'
require 'data_mapper'

require './fit_data'
require './fit_data_db'
require './activity'
require './user'


DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")
DataMapper.auto_upgrade!

puts "Just so you know, here is your database connection info:"
puts DataMapper.repository.adapter.options
puts

def get_data(client, token, secret, user_id, team, sep_userid, date_in_week)
  sunday = client.get_data(token, secret, user_id, date_in_week - date_in_week.wday - 7)
  monday = client.get_data(token, secret, user_id, date_in_week - date_in_week.wday - 6)
  tuesday = client.get_data(token, secret, user_id, date_in_week - date_in_week.wday - 5)
  wednesday = client.get_data(token, secret, user_id, date_in_week - date_in_week.wday - 4)
  thursday = client.get_data(token, secret, user_id, date_in_week - date_in_week.wday - 3)
  friday = client.get_data(token, secret, user_id, date_in_week - date_in_week.wday - 2)
  saturday = client.get_data(token, secret, user_id, date_in_week - date_in_week.wday - 1)

  name = sep_userid
  {name: name,
   steps: { sunday: sunday.steps,
            monday: monday.steps,
            tuesday: tuesday.steps,
            wednesday: wednesday.steps,
            thursday: thursday.steps,
            friday: friday.steps,
            saturday: saturday.steps
          },
   team: team
  }
end

def get_report(client, users, date)
  step_data = users
                .select{|u| !(u['token'].empty?)}
                .map {|u| get_data(client, u['token'], u['secret'], u['user_id'], u['team'], u['name'], date)}
  
  by_team = step_data
             .group_by{|u| u[:team]}
             .sort_by{|u| u[0]}

  range_string = "#{(date - date.wday - 7)} through #{(date - date.wday - 1)}"
  mail_body = "Weekly report for #{range_string}\n\n"

  by_team.each do |x|
    team_total = 0
    mail_body += "#{x[0]}\n"

    x[1].each do |i|
      mail_body += "#{i[:name]}  #{i[:steps][:sunday]}, #{i[:steps][:monday]}, #{i[:steps][:tuesday]}, #{i[:steps][:wednesday]}, #{i[:steps][:thursday]}, #{i[:steps][:friday]}, #{i[:steps][:saturday]} Total:#{i[:steps][:sunday]+i[:steps][:monday]+i[:steps][:tuesday]+i[:steps][:wednesday]+i[:steps][:thursday]+i[:steps][:friday]+i[:steps][:saturday]}\n"
	  team_total += i[:steps][:sunday]
	  team_total += i[:steps][:monday]
	  team_total += i[:steps][:tuesday]
	  team_total += i[:steps][:wednesday]
	  team_total += i[:steps][:thursday]
	  team_total += i[:steps][:friday]
	  team_total += i[:steps][:saturday]
  end

    mail_body += "Team total: #{team_total}\n"
    mail_body += "\n"
  end
  mail_body
end

CONFIG = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'config.json')))
users = User.all
date_to_use = Date.today

#puts get_report(FitData.new(CONFIG['consumer_key'], CONFIG['consumer_secret']), users, date_to_use)
puts get_report(FitDataDb.new, users, date_to_use)
