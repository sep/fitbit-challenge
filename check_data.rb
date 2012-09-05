require 'rubygems'
require 'bundler/setup'
require 'fitgem'
require 'awesome_print'
require 'date'

CONSUMER_KEY = '7556156012894ad0882b86dd67f3a416'
CONSUMER_SECRET = '442944ace4b54fddae26727e6d69c136'

def get_data(token, secret, user_id)
  client = Fitgem::Client.new({:consumer_key => CONSUMER_KEY, :consumer_secret => CONSUMER_SECRET, :token => token, :secret => secret, :user_id => user_id})
  access_token = client.reconnect(token, secret)
  {name: client.user_info['user']['fullName'], steps: client.activities_on_date(Date.today)['summary']['steps']}
end

users = [
  {token: '4844c8414d10bb9416184f556fd26c63', secret: 'b623243bdaee5ea0b6371e74fc738978', user_id: '23876M'}
  ]


data = users.map {|u| get_data(u[:token], u[:secret], u[:user_id]) }

data.each {|u| puts "#{u[:name]}   #{u[:steps]}"}
puts "Total: #{data.map{|u| u[:steps]}.inject(0){|s, t| s+t}}"


