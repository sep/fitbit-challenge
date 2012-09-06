require 'rubygems'
require 'bundler/setup'
require 'fitgem'
require 'awesome_print'
require 'date'

CONSUMER_KEY = '7556156012894ad0882b86dd67f3a416'
CONSUMER_SECRET = '442944ace4b54fddae26727e6d69c136'

DATA = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'users.json')))

def get_data(token, secret, user_id, team)
  client = Fitgem::Client.new({:consumer_key => CONSUMER_KEY, :consumer_secret => CONSUMER_SECRET, :token => token, :secret => secret, :user_id => user_id})
  {name: client.user_info['user']['fullName'],
   steps: { sunday: client.activities_on_date(DateTime.now - DateTime.now.wday - 7)['summary']['steps'],
            monday: client.activities_on_date(DateTime.now - DateTime.now.wday - 6)['summary']['steps'],
            tuesday: client.activities_on_date(DateTime.now - DateTime.now.wday - 5)['summary']['steps'],
            wednesday: client.activities_on_date(DateTime.now - DateTime.now.wday - 4)['summary']['steps'],
            thursday: client.activities_on_date(DateTime.now - DateTime.now.wday - 3)['summary']['steps'],
            friday: client.activities_on_date(DateTime.now - DateTime.now.wday - 2)['summary']['steps'],
            saturday: client.activities_on_date(DateTime.now - DateTime.now.wday - 1)['summary']['steps'],
          },
   team: team
  }
end

data = DATA.select{|u| !(u['token'].empty?)}.map {|u| get_data(u['token'], u['secret'], u['user_id'], u['team'])}

data = data.group_by{|u| u[:team]}

data.keys.each do |x|
	team_total = 0
	puts x
	data[x].each do |i|
		puts "#{i[:name]}  #{i[:steps][:sunday]},#{i[:steps][:monday]},#{i[:steps][:tuesday]},#{i[:steps][:wednesday]},#{i[:steps][:thursday]},#{i[:steps][:friday]},#{i[:steps][:saturday]} Total:#{i[:steps][:sunday]+i[:steps][:monday]+i[:steps][:tuesday]+i[:steps][:wednesday]+i[:steps][:thursday]+i[:steps][:friday]+i[:steps][:saturday]}"
		team_total += i[:steps][:sunday]
		team_total += i[:steps][:monday]
		team_total += i[:steps][:tuesday]
		team_total += i[:steps][:wednesday]
		team_total += i[:steps][:thursday]
		team_total += i[:steps][:friday]
		team_total += i[:steps][:saturday]
	end
	puts "Team total: #{team_total}"
	puts
end
