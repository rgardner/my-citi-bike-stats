=begin
  * Name: nyciti_user_stats.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 9/16/13
  * License: MIT
=end

require File.expand_path('../../lib/nyciti_bike/models/user.rb', __FILE__)
require File.expand_path('../../lib/nyciti_bike/web_scraper/citi_scraper.rb',
                          __FILE__)
require 'highline/import'
require 'yaml'

LOGIN_SUCCESS = 'Welcome To Citi Bike!'
LOGIN_INFO = YAML.load_file(File.expand_path('../../config/citi_account.yaml',
                            __FILE__))

driver = CitiCrawler.new
username = LOGIN_INFO['username']
password = LOGIN_INFO['password']

while driver.login(username, password) != LOGIN_SUCCESS
  puts "Wrong username / password"
  username = ask("Username: ")
  password = ask("Password: ")
end

puts LOGIN_SUCCESS

user = User.new(username)

user.bike_trips = driver.get_trips
printf("Total time:\t%s minutes\n", user.total_time)
printf("Cost per minute:\t$%s\n", user.effective_cost_per_minute)
printf("Cost per trip:\t$%s\n", user.effective_cost_per_trip)
