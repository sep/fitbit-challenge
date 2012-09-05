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
  {token: '4844c8414d10bb9416184f556fd26c63', secret: 'b623243bdaee5ea0b6371e74fc738978', user_id: '23876M', sep_userid: 'jcfuller'},
  {token: '1e6d4d6680de9f49a08d4c8c1406a6e2', secret: '650419b00fe0d88043c58b5950f7a978', user_id: '233MPC', sep_userid: 'mcterry'},
  {token: '73191b438042964c58d44d630d904e08', secret: '8d0a0ead3e63687cc1567047217fb368', user_id: '22NYYJ', sep_userid: 'rmschade'},
  {token: 'e460d33233feaa2d0997d1b35613f5b4', secret: '147e461520d58f0538920fb5e7fd7231', user_id: '238VWY', sep_userid: 'mdswanson'}
  ]


data = users.map {|u| get_data(u[:token], u[:secret], u[:user_id]) }

data.each {|u| puts "#{u[:name]}   #{u[:steps]}"}
puts "Total: #{data.map{|u| u[:steps]}.inject(0){|s, t| s+t}}"


