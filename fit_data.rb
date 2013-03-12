require 'fitgem'

class FitData
  def initialize(key, secret)
    @key = key
    @secret = secret
  end

  def get_data(token, secret, user_id, date)
    client = Fitgem::Client.new({:consumer_key => @key, :consumer_secret => @secret, :token => token, :secret => secret, :user_id => user_id})

    name = (client.user_info['user'] || {'fullName' => '?'})['fullName']
    steps = name == '?' ? 0 : client.activities_on_date(date)['summary']['steps']

    a = Activity.new
    a.user_id = user_id
    a.name = name
    a.steps = steps
    a.date = date

    return a
  end

end
