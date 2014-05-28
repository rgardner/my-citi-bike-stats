# My Citi Bike Stats

## Description
Learn more about how you use the Citi Bike program. After following the getting
started instructions, you'll be able to download your Citi Bike data and work
with it in CSV files.

## Getting Started
First download this repository and install its dependencies.
```
git clone https://github.com/rgardner/my-citi-bike-stats.git
cd my-citi-bike-stats
bundle
```

To download your Citi Bike data, you have three options:
  1. Run `./download_trips.rb` with no flags (it'll prompt you for your Citi
     Bike credentials)
  2. Run `./download_trips.rb -u USERNAME -p PASSWORD`, replacing `USERNAME`
     and `PASSWORD` with your Citi Bike credentials.
  3. `cp config.yml.example config.yml` and put your Citi Bike credentials in
     `config.yml` to avoid typing your credentials every time.

## The Data
The `download_trip.rb` script will go to
[your Citi Bike trips page](https://www.citibikenyc.com/member/trips) and
download each of the trips page by page. This script just downloads the raw
data, it **does not** do any data formatting or replacement.
