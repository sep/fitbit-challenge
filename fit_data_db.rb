class FitDataDb
  def get_data(token, secret, user_id, date)
    Activity.first(:date => date, :user_id => user_id) || Activity.new
  end
end
