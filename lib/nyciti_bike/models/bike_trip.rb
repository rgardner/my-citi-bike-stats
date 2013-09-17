=begin
  * Name: bike_trip.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 9/16/13
  * License: MIT
=end

require 'date'

class BikeTrip
  DATE_FORMAT = "%x"                       # current format as of 9/17/2013
  DURATION_REGEX = /(\d{1,2})m (\d{1,2})s/ # current format as of 9/17/2013

  attr_accessor :id, :start_location, :end_location, :date, :duration

  # Converts raw date string to Date Object
  def date=(date)
    @date = Date.strptime(date, DATE_FORMAT)
  end

  # Duration of trip in seconds
  def duration=(duration)
    secs_per_min = 60
    match = DURATION_REGEX.match(duration)
    @duration = match[1].to_i * secs_per_min + match[2].to_i
  end

  def to_csv
    "#{@id}, #{@start_location}, #{@end_location}, #{@date}, #{@duration}"
  end
end
