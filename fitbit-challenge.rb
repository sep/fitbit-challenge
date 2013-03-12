require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require './db'

CONFIG = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'config.json')))

class Array
  def take_if(n, cond)
    puts "here: #{cond}"
    return self unless cond
    self.take(n)
  end
end

get '/' do
 erb :index
end

get '/index.htm' do
  redirect '/'
end

get '/total' do
  # TODO: optimize.  run sql in database?
  activities = Activity.all
  sum_steps(activities).to_json
end

get '/team_leaderboard/?:count?' do |count|
  # TODO: optimize.  run sql in database?
  activities = Activity.all
  by_team = activities.group_by{|a| a.team}
  cnt_by_team = by_team.keys.inject([]){|memo, team_name| memo << {team: team_name, steps: sum_steps(by_team[team_name])}}
  cnt_by_team.sort_by{|s| s[:steps]}.reverse.take_if(get_count(count), !!count).to_json
end

get '/personal_leaderboard/?:count?' do |count|
  # TODO: optimize.  run sql in database?
  activities = Activity.all
  by_person = activities.group_by{|a| a.user_id}
  cnt_by_person = by_person.keys.inject([]){|memo, user_id| memo << {person: by_person[user_id].last.name, steps: sum_steps(by_person[user_id])}}
  cnt_by_person.sort_by{|s| s[:steps]}.reverse.take_if(get_count(count), !!count).to_json
end

get '/team_week/?:count?' do |count|
  # TODO: optimize.  run sql in database?
  activities = Activity.all(:date => ((Date.today-Date.today.wday)..Date.today))
  by_team = activities.group_by{|a| a.team}
  cnt_by_team = by_team.keys.inject([]){|memo, team_name| memo << {team: team_name, steps: sum_steps(by_team[team_name])}}
  cnt_by_team.sort_by{|s| s[:steps]}.reverse.take_if(get_count(count), !!count).to_json
end

get '/personal_week/?:count?' do |count|
  # TODO: optimize.  run sql in database?
  activities = Activity.all(:date => ((Date.today-Date.today.wday)..Date.today))
  by_person = activities.group_by{|a| a.user_id}
  cnt_by_person = by_person.keys.inject([]){|memo, user_id| memo << {person: by_person[user_id].last.name, steps: sum_steps(by_person[user_id])}}
  cnt_by_person.sort_by{|s| s[:steps]}.reverse.take_if(get_count(count), !!count).to_json
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

def get_count(count_param)
  !!count_param ? count_param.to_i : -1
end

def sum_steps(enum)
  enum.inject(0){|sum, a| sum+a.steps}
end
