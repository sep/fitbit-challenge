#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'date'
require 'json'

require 'data_mapper'
require './fit_data'
require './activity'
require './user'

CONFIG = JSON.parse(File.read(File.join(File.dirname(__FILE__), '../config.json')))

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")
DataMapper.auto_upgrade!

DATA = User.all

def get_activity(token, secret, user_id, date, team, name)
  client = FitData.new(CONFIG['consumer_key'], CONFIG['consumer_secret'])
  activity = client.get_data(token, secret, user_id, date)
  activity.team = team
  activity.name = name
  activity
end

days_ago = ARGV.first.to_i || 0
data_date = Date.today - days_ago
puts data_date
puts ENV['DATABASE_URL'] 

if data_date < Date.parse(CONFIG['start_date'])
  puts "Date is before contest start date.  Quitting"
  exit
end

DATA.select{|u| !(u.token.empty?)}.each do |u|
  begin
    puts u.name;
    activity = get_activity(u.token, u.secret, u.user_id, data_date, u.team, u.name)
    Activity.all(:date => data_date, :user_id => u.user_id).destroy
    activity.save
  rescue Exception => e
    $stderr.puts "errored on #{u.name}" + e.to_s
  end
end
