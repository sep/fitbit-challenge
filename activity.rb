require 'data_mapper'

class Activity
  include DataMapper::Resource

  property :id, Serial
  property :user_id, String
  property :name, String
  property :date, DateTime
  property :steps, Integer
  property :team, String
end

