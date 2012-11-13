require 'fitgem'
require './activity'

require 'rubygems'
require 'bundler/setup'
require 'date'
require 'json'

require 'data_mapper'
require './fit_data'
require './activity'
require './user'

#CONSUMER_KEY = '7556156012894ad0882b86dd67f3a416'
#CONSUMER_SECRET = '442944ace4b54fddae26727e6d69c136'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")

class FitData
  def initialize(key, secret)
  end

  def get_data(token, secret, user_id, date)
    Activity.first(:date => date, :user_id => user_id)
  end

end
