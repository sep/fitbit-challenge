require './activity'

class FitData
  def initialize(key, secret)
    @key = key
    @secret = secret
  end

  def get_data(token, secret, user_id, date)
    client = Fitgem::Client.new({:consumer_key => @key, :consumer_secret => @secret, :token => token, :secret => secret, :user_id => user_id})

    a = Activity.new
    a.user_id = user_id
    a.name = client.user_info['user']['fullName']
    a.steps = client.activities_on_date(date)['summary']['steps']

    return a
  end

end
