require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")

require './activity'

DataMapper.auto_upgrade!

get '/' do
  'hello world'
end

get '/count' do
  "number of activities: #{Activity.all.count}"
end
