=begin
  * Name: nyciti_driver.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 9/16/13
  * License: MIT
=end

require File.expand_path('../../lib/nyciti_bike/models/bike_trip.rb', __FILE__)
require File.expand_path('../../lib/nyciti_bike/models/user.rb', __FILE__)
require File.expand_path('../../lib/nyciti_bike/web_crawler/citi_crawler.rb',
                          __FILE__)
require 'highline/import'
require 'yaml'

LOGIN_SUCCESS = 'Welcome To Citi Bike!'
login_info = YAML.load_file(File.expand_path('../../config/citi_account.yaml',
                            __FILE__))

driver = CitiCrawler.new
username = login_info['username']
password = login_info['password']

while driver.login(username, password) != LOGIN_SUCCESS
  puts "Wrong username / password"
  username = ask("Username: ")
  password = ask("Password: ")
end

puts LOGIN_SUCCESS

user = User.new(username)

user.bike_trips = driver.get_trips
user.bike_trips_to_csv
