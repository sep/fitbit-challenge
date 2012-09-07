require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")

require './activity'

DataMapper.auto_upgrade!

get '/' do
  'hello world'
end

get '/team_leaderboard' do
  activities = Activity.all
  by_team = activities.group_by{|a| a.team}
  cnt_by_team = by_team.keys.inject([]){|memo, obj| memo << {team: obj, steps: by_team[obj].inject(0){|sum, a| sum+a.steps}}}
  cnt_by_team.sort_by{|s| s[:steps]}.reverse.to_json
end
