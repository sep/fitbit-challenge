require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data.db")

Dir['./models/*.rb'].each { |file| require "./#{file}" }

DataMapper.auto_upgrade!