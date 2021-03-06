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

start_date = nil
end_date   = nil

# Begin downloading trips.
agent.get(TRIPS_URL)
loop do
  break unless agent.page.title == TRIPS_PAGE_TITLE

  rows = Nokogiri::HTML(agent.page.body).xpath('//table/tbody/tr')

  # e.x. dates = 'May 01, 2014 - May 02, 2014'
  dates = Nokogiri::HTML(agent.page.body).at_xpath('//h2/text()').to_s
  puts "Downloading data from #{dates}"
  dates = dates.split
  month = dates[0].downcase
  year  = dates[2]

  start_date = dates[0..2].join(' ')
  end_date = dates[4..6].join(' ') unless end_date

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
  file.close if file

  # Click the 'next page' link; returns nil if it doesn't exist.
  break unless agent.click('>')
end

printf "\nSuccess! Downloaded data from: #{start_date} - #{end_date}\n"
