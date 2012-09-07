require 'rubygems'
require 'bundler/setup'
require 'fitgem'

consumer_key = '7556156012894ad0882b86dd67f3a416'
consumer_secret = '442944ace4b54fddae26727e6d69c136'

client = Fitgem::Client.new({:consumer_key => consumer_key, :consumer_secret => consumer_secret})

request_token = client.request_token
token = request_token.token
secret = request_token.secret

puts "Go to http://www.fitbit.com/oauth/authorize?oauth_token=#{token} and then enter the verifier code below and hit Enter"
verifier = gets.chomp

access_token = client.authorize(token, secret, { :oauth_verifier => verifier })

puts "Verifier is: "+verifier
puts "\"token\": \"#{access_token.token}\", \"secret\": \"#{access_token.secret}\", \"user_id\": \"#{access_token.params[:encoded_user_id]}\","
