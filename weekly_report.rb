require 'rubygems'
require 'bundler/setup'
require 'fitgem'
require 'date'
require 'mail'

CONSUMER_KEY = '7556156012894ad0882b86dd67f3a416'
CONSUMER_SECRET = '442944ace4b54fddae26727e6d69c136'

DATA = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'users.json')))

def get_data(token, secret, user_id, team)
  client = Fitgem::Client.new({:consumer_key => CONSUMER_KEY, :consumer_secret => CONSUMER_SECRET, :token => token, :secret => secret, :user_id => user_id})
  now = DateTime.now
  {name: client.user_info['user']['fullName'],
   steps: { sunday: client.activities_on_date(now - now.wday - 7)['summary']['steps'],
            monday: client.activities_on_date(now - now.wday - 6)['summary']['steps'],
            tuesday: client.activities_on_date(now - now.wday - 5)['summary']['steps'],
            wednesday: client.activities_on_date(now - now.wday - 4)['summary']['steps'],
            thursday: client.activities_on_date(now - now.wday - 3)['summary']['steps'],
            friday: client.activities_on_date(now - now.wday - 2)['summary']['steps'],
            saturday: client.activities_on_date(now - now.wday - 1)['summary']['steps'],
          },
   team: team
  }
end

data = DATA.select{|u| !(u['token'].empty?)}.map {|u| get_data(u['token'], u['secret'], u['user_id'], u['team'])}

data = data.group_by{|u| u[:team]}
data = data.sort_by{|u| u[0]}

range_string = "#{(DateTime.now - DateTime.now.wday - 7).to_date} through #{(DateTime.now - DateTime.now.wday - 1).to_date}"
mail_body = "Weekly report for #{range_string}\n\n"

data.each do |x|
  team_total = 0
  mail_body += "#{x[0]}\n"

  x[1].each do |i|
    mail_body += "#{i[:name]}  #{i[:steps][:sunday]},#{i[:steps][:monday]},#{i[:steps][:tuesday]},#{i[:steps][:wednesday]},#{i[:steps][:thursday]},#{i[:steps][:friday]},#{i[:steps][:saturday]} Total:#{i[:steps][:sunday]+i[:steps][:monday]+i[:steps][:tuesday]+i[:steps][:wednesday]+i[:steps][:thursday]+i[:steps][:friday]+i[:steps][:saturday]}\n"
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
   subject "Weekly New Orleans Walk Challenge Report #{range_string}"
      body mail_body
end

mail.deliver!