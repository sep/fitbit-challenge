require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")

class Activity
  include DataMapper::Resource

  property :id, Serial
  property :user_id, String
  property :name, String
  property :date, DateTime
  property :steps, Integer
  property :team, String
end

DataMapper.auto_upgrade!

get '/' do
  'hello world'
end

get '/count' do
  "number of activities: #{Activity.all.count}"
end
