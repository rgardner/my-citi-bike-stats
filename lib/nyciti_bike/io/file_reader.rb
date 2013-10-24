=begin
  * Name: file_reader.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 10/24/13
  * License: MIT
=end

require File.expand_path('../../models/bike_trip.rb', __FILE__)
require File.expand_path('../../models/user.rb',      __FILE__)
require 'date'

class FileReader
  USER_REGEX  = /^(\w+)$/

  # Given an absolute path (str) to file, return user with name and trips
  def self.read_trips(file)
    user = nil
    trips = []
    File.open(file) do |f|
      username = f.gets.match(USER_REGEX)
      user = User.new(username)

      f.each do |record|
        id, start_loc, end_loc, date, duration = record.chomp.split(',')

        trip = BikeTrip.new
        trip.id = id
        trip.start_location = start_loc
        trip.end_location = end_loc
        trip.date = date
        trip.duration = duration.to_i
        trips << trip
      end
      user.bike_trips = trips
    end
    user
  end

end
