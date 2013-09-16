=begin
  * Name: bike_trip.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 9/16/13
  * License: MIT
=end

class BikeTrip

  attr_accessor :id, :start_location, :end_location, :date, :duration

  def to_csv
    "#{@id}, #{@start_location}, #{@end_location}, #{@date}, #{@duration}"
  end
end
