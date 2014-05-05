#!/usr/bin/env ruby -wU

# Name: citi_scraper.rb
# Description: Download trips to CSV files
# Author: Bob Gardner
# Date: 5/2/14
# License: MIT

require 'mechanize'
require 'trollop'

LoginError = Class.new(StandardError)

REPORT_DIR = 'data'
LOGIN_URL = 'https://citibikenyc.com/login'
TRIPS_URL = 'https://citibikenyc.com/member/trips'

LOGIN_PAGE_TITLE = 'Login | Citi Bike'
TRIPS_PAGE_TITLE = 'Trips | Citi Bike'

PAGINATION_CSS = 'nav.pagination a/text()'

MIN_TRIP_DURATION = 2 # in minutes

# Get command line options.
opts = Trollop.options do
  banner 'Download Citi Bike trip data'
  opt :dry_run,  'Log trips to stdout, do not save to file.'
  opt :username, 'Your Citi Bike username', type: :string
  opt :password, 'Your Citi Bike password', type: :string
end

# Prepare File Saving
unless opts[:dry_run]
  Dir.mkdir(REPORT_DIR) unless File.exist?(REPORT_DIR)
  Dir.chdir(REPORT_DIR)
end

# Prepare login information. Try command line options, config file, and fall
#   back on STDIN.
username = opts[:username]
password = opts[:password]
unless username && password
  if File.exist?(File.join(__dir__, 'config.yml'))
    config = YAML.load_file(File.join(__dir__, 'config.yml'))
    username = config['citibike_username']
    password = config['citibike_password']
  else
    print 'Enter your Citi Bike username: '
    username = gets.chomp
    print 'Enter your Citi Bike password: '
    password = gets.chomp
  end
end

# Login.
agent = Mechanize.new
agent.get(LOGIN_URL)
agent.page.forms[0]['subscriberUsername'] = username
agent.page.forms[0]['subscriberPassword'] = password
agent.page.forms[0].submit
if agent.page.title == LOGIN_PAGE_TITLE
  fail LoginError, 'Invalid username or password'
end

# Begin downloading trips.
page = 1
loop do
  # Visit the trips page.
  trips_url = "#{TRIPS_URL}/#{page}"
  agent.get(trips_url)
  break unless agent.page.title == TRIPS_PAGE_TITLE

  # Exclude in-progress and invalid trips.
  rows = Nokogiri::HTML(agent.page.body).xpath('//table/tbody/tr')
  rows = rows.reject do |row|
    duration = row.at_xpath('td[6]/text()').to_s.match(/(\d{1,2})m/)
    !duration || (duration.captures[0].to_i < MIN_TRIP_DURATION)
  end

  # e.x. dates = 'May 01, 2014 - May 02, 2014'
  dates = Nokogiri::HTML(agent.page.body).at_xpath('//h2/text()').to_s
  puts "Downloading data from #{dates}"
  dates = dates.split
  month = dates[0].downcase
  year  = dates[2]

  # Setup file
  file = nil
  unless opts[:dry_run]
    filename = "#{month}-#{year}.csv"
    file = File.open(filename, 'w')
  end

  rows.each do |row|
    attributes = []
    (1..6).each do |i|
      attributes.push(row.at_xpath("td[#{i}]/text()").to_s.strip)
    end

    # Write to stdout or file
    if opts[:dry_run]
      puts attributes.join(',')
    else
      file.puts attributes.join(',')
    end
  end
  file.close unless file.nil?

  # Determine if last webpage by checking pagination
  last_nav_link = Nokogiri::HTML(agent.page.body).css(PAGINATION_CSS)[-1].to_s
  break if last_nav_link['›'].nil?

  page += 1
end
