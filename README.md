# What is it?

http://sepgetsfit.herokuapp.com

# How to contribute

1. Fork it.
2. Make a feature branch.
3. Add your feature.
4. Make a pull request.

# How to set it up for your own fitbit challenge

1. Fork it.
2. Change the values in `config.json`
3. Go.

## Adding users

For now... use the `setup.rb` script.

## Updating the data

For now... call `bin/archive_data.rb [N]` or `heroku run archive_data.rb [N]`, periodically.  N is the number of days ago to refresh the data for.  The default is 0, which means refresh today's data.  Passing 1 will refresh yesterday's data.
