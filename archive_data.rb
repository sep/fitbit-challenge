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
DATA = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'users.json')))

def store(token, secret, user_id, date, team, sep_userid)
  client = FitData.new(CONSUMER_KEY, CONSUMER_SECRET)
  activity = client.get_data(token, secret, user_id, date)
  activity.team = team
  activity.name ||= sep_userid
  activity.save
end

days_ago = ARGV.first.to_i || 0
#TODO: destroy data for this day - something like Activity.destroy where date = Date.today - days_ago
DATA.select{|u| !(u['token'].empty?)}.each {|u| store(u['token'], u['secret'], u['user_id'], Date.today - days_ago, u['team'], u['sep_userid'])}
