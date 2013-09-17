=begin
  * Name: citi_crawler.rb
  * Description: 
  * Author: Bob Gardner
  * Date: 9/16/13
  * License: MIT
=end

require File.expand_path('../../models/bike_trip.rb', __FILE__)
require 'mechanize'

class CitiCrawler

  def initialize
    @agent = Mechanize.new
  end

  def login(username, password)
    @agent.get('https://citibikenyc.com/login')
    @agent.page.forms[0]['subscriberUsername'] = username
    @agent.page.forms[0]['subscriberPassword'] = password
    @agent.page.forms[0].submit
    @agent.page.title
  end

  def get_trips
    @agent.click('Trips')
    rows = Nokogiri::HTML(@agent.page.body).xpath('//table/tbody/tr')
    trips = rows.collect do |row|
      trip = BikeTrip.new
      [
        [:id, 'td[1]/text()'],
        [:start_location, 'td[2]/text()'],
        [:end_location, 'td[4]/text()'],
        [:date, 'td[5]/text()'],
        [:duration, 'td[6]/text()'],
      ].each do |name, xpath|
        trip.send("#{name}=", row.at_xpath(xpath).to_s.strip)
      end
      trip
    end
    trips
  end

end
