=begin
  * Name: user.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 10/24/13
  * License: MIT
=end

require File.expand_path('../bike_trip.rb', __FILE__)

class User
  ANNUAL_COST = 95.0                        # dollars; current as of 10/24/2013
  REPORT_DIR = File.expand_path('../../../../output/trip_logs', __FILE__)
  SECS_PER_MIN = 60.0

  @@total_count = 0
  
  attr_reader   :name, :id
  attr_accessor :bike_trips

  def initialize(name, bike_trips = [])
    @id = @@total_count
    @@total_count += 1
    @name = name
    @bike_trips = bike_trips
  end

  # sum total of the duration of each trip in seconds
  def total_time
    @bike_trips.inject(0) { |sum, trip| sum += trip.duration }
  end

  # average cost per minute biking
  def effective_cost_per_minute
    ANNUAL_COST * SECS_PER_MIN / total_time
  end

  # average cost per trip
  def effective_cost_per_trip
    ANNUAL_COST / @bike_trips.count
  end

  def bike_trips_to_csv
    Dir.mkdir(REPORT_DIR) unless File.exists?(REPORT_DIR)
    Dir.chdir(REPORT_DIR)
    filename = DateTime.now.to_s                # Ex. 2001-02-03T04:05:06-07:00
    File.open("#{filename}.csv", "w") do |report|
      report.puts("#{name}")
      @bike_trips.each do |trip|
        report.puts(trip.to_csv)
      end
    end
  end

end
