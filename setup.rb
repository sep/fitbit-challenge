require 'rubygems'
require 'bundler/setup'
require 'fitgem'

require 'data_mapper'
require './fit_data'
require './activity'
require './user'

CONFIG = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'config.json')))

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")
DataMapper.auto_upgrade!

puts "Just so you know, here is your database connection info:"
puts DataMapper.repository.adapter.options
puts

client = Fitgem::Client.new({:consumer_key => CONFIG['consumer_key'], :consumer_secret => CONFIG['consumer_secret']})

request_token = client.request_token
token = request_token.token
secret = request_token.secret

puts "Name: "
name = gets.chomp
puts "Team: "
team = gets.chomp

puts "Go to http://www.fitbit.com/oauth/authorize?oauth_token=#{token} and then enter the verifier code below and hit Enter"
verifier = gets.chomp

access_token = client.authorize(token, secret, { :oauth_verifier => verifier })

puts "Verifier is: "+verifier

u = User.new
u.user_id = access_token.params[:encoded_user_id]
u.token = access_token.token
u.secret = access_token.secret
u.name = name
u.team = team
puts u.save.to_s
