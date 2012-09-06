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
  access_token = client.reconnect(token, secret)
  {name: client.user_info['user']['fullName'], steps: client.activities_on_date(Date.today)['summary']['steps'], team: team}
end

data = DATA.map {|u| get_data(u['token'], u['secret'], u['user_id'], u['team'])}

data = data.group_by{|u| u[:team]}

data.keys.each do |x|
	team_total = 0
	puts x
	data[x].each do |i|
		puts "#{i[:name]}   #{i[:steps]}"
		team_total += i[:steps]
	end
	puts "Team total: #{team_total}"
	puts
end
