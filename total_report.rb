require 'rubygems'
require 'bundler/setup'
require 'date'
require 'mail'

require './db'
require './fit_data'
require './fit_data_db'

puts "Just so you know, here is your database connection info:"
puts DataMapper.repository.adapter.options
puts

def get_report(client, users, dates)

  all_data = dates.map do |date|
    users.
      select{|u| !(u['token'].empty?)}.
      map do |u|
        $stderr.puts("#{u['user_id'] - date}")
        {:name => u['user_id'], :steps => client.get_data(u['token'], u['secret'], u['user_id'], date), :date => date}
      end
  end

  $stdout.puts "userid,#{dates.map{|d| d}.join(',')}"

  user_data = all_data.group_by{|d| d[:user_id]}
  user_data.keys.each do |u|
    this_user = user_data[u]
    ordered_steps = this_user.sort_by{|d| d[:date]}.map{|d| d[:steps]}

    $stdout.puts "#{u},#{ordered_steps.join(',')}"
  end
end
  
CONFIG = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'config.json')))
users = User.all
dates = (Date.new(2012, 9, 5)..Date.today)

users = users.take(2)
dates = dates.take(2)

get_report(FitData.new(CONFIG['consumer_key'], CONFIG['consumer_secret']), users, dates)
