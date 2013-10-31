#!/usr/bin/env ruby
=begin
  * Name: nyciti_driver.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 10/24/13
  * License: MIT
=end

require File.expand_path('../../lib/nyciti_bike/models/user.rb', __FILE__)
require File.expand_path('../../lib/nyciti_bike/web_scraper/citi_scraper.rb',
                          __FILE__)
require File.expand_path('../../lib/nyciti_bike/io/file_reader.rb', __FILE__)
require 'highline/import'
require 'optparse'
require 'ostruct'
require 'yaml'

FILE_FORMAT = /.csv$/
LOGIN_SUCCESS = 'Welcome To Citi Bike!'
LOGIN_INFO = YAML.load_file(File.expand_path('../../config/citi_account.yaml',
                            __FILE__))
MINS_PER_HOUR = 60.0
SECS_PER_MIN  = 60.0


class Optparse

  def self.parse(args)
    # Set default values for options
    options                = OpenStruct.new
    options.trips_file     = nil
    options.trips          = 1
    options.save           = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: nyciti_driver.rb [options]"
      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-t", "--trip N", Integer, "Print last N trips") do |n|
        options.trips = n
      end

      opts.on("-s", "--save", "Save date from citibikenyc.com to file") do |v|
        options.save = v
      end

      opts.separator ""
      opts.separator "Common options:"

      # Prints options summary
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end

end

# Given time in seconds, returns "3 hrs, 25mins"
def formatted_time(time_in_secs)
  time_in_hours = time_in_secs / (SECS_PER_MIN * MINS_PER_HOUR)
  time_in_mins  = (time_in_secs / SECS_PER_MIN) % MINS_PER_HOUR
  "#{time_in_hours.to_i} hrs, #{time_in_mins.to_i} mins"
end

options = Optparse.parse(ARGV)
trips_file = ARGV[0]

user = nil

if trips_file && trips_file.match(FILE_FORMAT)
  user = FileReader.read_trips(trips_file)
else
  driver   = CitiCrawler.new
  username = LOGIN_INFO['username']
  password = LOGIN_INFO['password']

  while driver.login(username, password) != LOGIN_SUCCESS
    puts "Wrong username / password"
    username = ask("Username: ")
    password = ask("Password: ") { |q| q.echo = "*" }
  end

  puts LOGIN_SUCCESS

  user = User.new(username)
  user.bike_trips = driver.get_trips
  user.bike_trips_to_csv if options.save
end

time_in_mins   = user.total_time / SECS_PER_MIN
time_str       = formatted_time(user.total_time)
printf("Total time:\t\t%d minutes (%s)\n", time_in_mins, time_str)
printf("Cost per minute:\t$%.2f\n",   user.effective_cost_per_minute)
printf("Cost per trip:\t\t$%.2f\n",   user.effective_cost_per_trip)

user.bike_trips.reverse.each_with_index do |trip, i|
  break if i >= options.trips
  puts trip.to_csv
end
