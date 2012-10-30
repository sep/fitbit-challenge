require 'rubygems'
require 'bundler/setup'
require 'date'
require 'mail'
require './fit_data_db'

CONSUMER_KEY = '7556156012894ad0882b86dd67f3a416'
CONSUMER_SECRET = '442944ace4b54fddae26727e6d69c136'

DATA = User.all

def get_data(token, secret, user_id, team, sep_userid)
  client = FitData.new(CONSUMER_KEY, CONSUMER_SECRET)
  now = Date.today
  sunday = client.get_data(token, secret, user_id, now - now.wday - 7)
  monday = client.get_data(token, secret, user_id, now - now.wday - 6)
  tuesday = client.get_data(token, secret, user_id, now - now.wday - 5)
  wednesday = client.get_data(token, secret, user_id, now - now.wday - 4)
  thursday = client.get_data(token, secret, user_id, now - now.wday - 3)
  friday = client.get_data(token, secret, user_id, now - now.wday - 2)
  saturday = client.get_data(token, secret, user_id, now - now.wday - 1)
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

data = DATA.select{|u| !(u['token'].empty?)}.map {|u| get_data(u['token'], u['secret'], u['user_id'], u['team'], u['name'])}

data = data.group_by{|u| u[:team]}
data = data.sort_by{|u| u[0]}

range_string = "#{(DateTime.now - DateTime.now.wday - 7).to_date} through #{(DateTime.now - DateTime.now.wday - 1).to_date}"
mail_body = "Weekly report for #{range_string}\n\n"

data.each do |x|
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

mail_options = { 
    :address => 'mail.sep.com',
    :port => '25',
    :enable_starttls_auto => false
  }

Mail.defaults do
  delivery_method :smtp, mail_options
end

mail = Mail.new do
      from 'noreply@sep.com'
        to 'trimble@sep.com'
   subject "Weekly New Orleans Walk Challenge Report #{range_string} (Database)"
      body mail_body
end

mail.deliver!
