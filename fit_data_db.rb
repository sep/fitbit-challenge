require './activity'

class FitDataDb
  def get_data(token, secret, user_id, date)
    Activity.first(:date => date, :user_id => user_id)
  end
end
