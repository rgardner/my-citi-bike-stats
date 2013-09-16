=begin
  * Name: user.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 9/16/13
  * License: MIT
=end

require File.expand_path('../bike_trip.rb', __FILE__)

class User
  REPORT_DIR = File.expand_path('../../../../spec/fixtures/reports', __FILE__)

  @@total_count = 0
  
  attr_reader   :name, :id
  attr_accessor :bike_trips

  def initialize(name)
    @id = @@total_count
    @@total_count += 1
    @name = name
    @bike_trips = []
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
