require 'data_mapper'

class User
  include DataMapper::Resource

  property :id, Serial
  property :user_id, String
  property :name, String
  property :team, String
  property :token, String
  property :secret, String
end

