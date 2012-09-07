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
  # TODO: optimize.  run sql in database
  activities = Activity.all
  by_team = activities.group_by{|a| a.team}
  cnt_by_team = by_team.keys.inject([]){|memo, team_name| memo << {team: team_name, steps: by_team[team_name].inject(0){|sum, a| sum+a.steps}}}
  cnt_by_team.sort_by{|s| s[:steps]}.reverse.to_json
end

get '/personal_leaderboard' do
  # TODO: optimize.  run sql in database
  activities = Activity.all
  by_person = activities.group_by{|a| a.user_id}
  cnt_by_person = by_person.keys.inject([]){|memo, user_id| memo << {person: by_person[user_id].first.name, steps: by_person[user_id].inject(0){|sum, a| sum+a.steps}}}
  cnt_by_person.sort_by{|s| s[:steps]}.reverse.to_json
end
