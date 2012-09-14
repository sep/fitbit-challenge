#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'date'
require 'json'

require 'data_mapper'
require './fit_data'
require './activity'

CONSUMER_KEY = '7556156012894ad0882b86dd67f3a416'
CONSUMER_SECRET = '442944ace4b54fddae26727e6d69c136'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")
DataMapper.auto_upgrade!

DATA = JSON.parse(File.read(File.join(File.dirname(__FILE__), '../users.json')))

def store(token, secret, user_id, date, team, sep_userid)
  client = FitData.new(CONSUMER_KEY, CONSUMER_SECRET)
  activity = client.get_data(token, secret, user_id, date)
  activity.team = team
  activity.name ||= sep_userid
  activity.save
end

days_ago = ARGV.first.to_i || 0
data_date = Date.today - days_ago
puts data_date
puts ENV['DATABASE_URL'] 

if data_date < Date.new(2012, 9, 5)
  puts "Date is before contest start date.  Quitting"
  exit
end

DATA.select{|u| !(u['token'].empty?)}.each do |u|
  begin
    puts u['sep_userid'];
    Activity.all(:date => data_date, :user_id => u['user_id']).destroy
    store(u['token'], u['secret'], u['user_id'], data_date, u['team'], u['sep_userid'])
  rescue
    $stderr.puts "errored on #{u['sep_userid']}"
  end
end
