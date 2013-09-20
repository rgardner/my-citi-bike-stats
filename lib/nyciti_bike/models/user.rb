=begin
  * Name: user.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 9/16/13
  * License: MIT
=end

require File.expand_path('../bike_trip.rb', __FILE__)

class User
  ANNUAL_COST = 95.0                         # dollars; current as of 9/17/2013
  REPORT_DIR = File.expand_path('../../../../output/raw', __FILE__)
  SECS_PER_MIN = 60.0

  @@total_count = 0
  
  attr_reader   :name, :id
  attr_accessor :bike_trips

  def initialize(name)
    @id = @@total_count
    @@total_count += 1
    @name = name
    @bike_trips = []
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
    File.open("user_#{@name}.csv", "w") do |report|
      @bike_trips.each do |trip|
        report.puts(trip.to_csv)
      end
    end
  end

end
