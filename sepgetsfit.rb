require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")

require './activity'

DataMapper.auto_upgrade!

get '/' do
 redirect '/index.htm'
end

get '/total' do
  # TODO: optimize.  run sql in database?
  activities = Activity.all
  sum_steps(activities).to_json
end

get '/team_leaderboard' do
  # TODO: optimize.  run sql in database?
  activities = Activity.all
  by_team = activities.group_by{|a| a.team}
  cnt_by_team = by_team.keys.inject([]){|memo, team_name| memo << {team: team_name, steps: sum_steps(by_team[team_name])}}
  cnt_by_team.sort_by{|s| s[:steps]}.reverse.to_json
end

get '/personal_leaderboard' do
  # TODO: optimize.  run sql in database?
  activities = Activity.all
  by_person = activities.group_by{|a| a.user_id}
  cnt_by_person = by_person.keys.inject([]){|memo, user_id| memo << {person: by_person[user_id].last.name, steps: sum_steps(by_person[user_id])}}
  cnt_by_person.sort_by{|s| s[:steps]}.reverse.take(10).to_json
end

get '/team_week' do
  # TODO: optimize.  run sql in database?
  activities = Activity.all(:date => ((Date.today-Date.today.wday)..Date.today))
  by_team = activities.group_by{|a| a.team}
  cnt_by_team = by_team.keys.inject([]){|memo, team_name| memo << {team: team_name, steps: sum_steps(by_team[team_name])}}
  cnt_by_team.sort_by{|s| s[:steps]}.reverse.take(3).to_json
end

get '/personal_week' do
  # TODO: optimize.  run sql in database?
  activities = Activity.all(:date => ((Date.today-Date.today.wday)..Date.today))
  by_person = activities.group_by{|a| a.user_id}
  cnt_by_person = by_person.keys.inject([]){|memo, user_id| memo << {person: by_person[user_id].last.name, steps: sum_steps(by_person[user_id])}}
  cnt_by_person.sort_by{|s| s[:steps]}.reverse.take(3).to_json
end

get '/member_contributions' do
  # TODO: optimize.  run sql in database?
  activities = Activity.all
  by_team = activities.group_by{|a| a.team}

  overall = []
  cnt_by_team = by_team.keys.each do |team_name|
    member_data = by_team[team_name].group_by{|t| t.user_id}

    overall << {team: team_name, members: member_data.keys.map{|user_id| {name: member_data[user_id].last.name, steps: sum_steps(member_data[user_id])}}}
  end 
  overall.sort_by{|d| d[:team]}.to_json
end

def sum_steps(enum)
  enum.inject(0){|sum, a| sum+a.steps}
end
