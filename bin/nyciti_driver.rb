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

LOGIN_SUCCESS = 'Welcome To Citi Bike!'
LOGIN_INFO = YAML.load_file(File.expand_path('../../config/citi_account.yaml',
                            __FILE__))
SECS_PER_MIN = 60.0

class Optparse

  def self.parse(args)
    # Set default values for options
    options                = OpenStruct.new
    options.trips_file     = nil
    options.trips          = 1
    options.report_full    = true

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: nyciti_driver.rb [options]"
      opts.separator ""
      opts.separator "Specific options:"

      # Optional arguments
      opts.on("-f", "--file [trips.csv]",
              "Use specified file for trips and user information;",
              "  otherwise, download user data from citibikenyc.com") do |file|
        options.trips_file = file
      end

      opts.on("-t", "--trip N", Integer, "Print last N trips") do |n|
        options.trips = n
      end

      opts.on("-s", "--short", "Print short user report") do |v|
        options.report_full = v
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

options = Optparse.parse(ARGV)

user = nil

if options.trips_file
  user = FileReader.read_trips(options.trips_file)
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
  user.bike_trips_to_csv
end

if options.full_report
  # TODO: add full report here; for now, same as simple
  printf("Total time:\t\t%d minutes\n", user.total_time / SECS_PER_MIN)
  printf("Cost per minute:\t$%.2f\n",   user.effective_cost_per_minute)
  printf("Cost per trip:\t\t$%.2f\n",   user.effective_cost_per_trip)
else
  printf("Total time:\t\t%d minutes\n", user.total_time / SECS_PER_MIN)
  printf("Cost per minute:\t$%.2f\n",   user.effective_cost_per_minute)
  printf("Cost per trip:\t\t$%.2f\n",   user.effective_cost_per_trip)
end

user.bike_trips.reverse.each_with_index do |trip, i|
  break if i >= options.trips
  puts trip.to_csv
end
