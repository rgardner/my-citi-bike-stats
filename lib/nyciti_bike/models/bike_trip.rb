=begin
  * Name: bike_trip.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 10/24/13
  * License: MIT
=end

require 'date'

class BikeTrip
  DATE_FORMAT = "%D"                         # citibike format as of 10/24/2013
  DURATION_REGEX = /(\d{1,2})m (\d{1,2})s/   # citibike format as of 10/24/2013
  SECS_PER_MIN = 60

  attr_accessor :id, :start_location, :end_location, :date, :duration

  # Converts raw date string to Date Object
  def date=(date)
    @date = Date.strptime(date, DATE_FORMAT)
  end

  # Duration of trip in seconds
  def duration=(duration)
    if duration.is_a? Integer
      @duration = duration
    else
      match = DURATION_REGEX.match(duration)
      @duration = match[1].to_i * SECS_PER_MIN + match[2].to_i
    end
  end

  def to_csv
    date_formatted = @date.strftime(DATE_FORMAT)
    "#{@id},#{@start_location},#{@end_location},#{date_formatted},#{@duration}"
  end
end
