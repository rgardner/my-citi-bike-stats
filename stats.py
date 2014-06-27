#
import HTMLParser
import os
import pandas as pd
# import re

pieces = []
columns = ['trip', 'start station', 'start time',
           'end station', 'end time', 'duration']

for filename in os.listdir('data/'):
    if not filename.endswith('.csv'):
        continue

    # e.g. filename = 'april-2014.csv'
    month, year = filename[:-4].split('-')
    path = 'data/%s' % filename

    frame = pd.read_csv(path, names=columns)
    frame['month'] = month
    frame['year'] = year

    pieces.append(frame)

trips = pd.concat(pieces, ignore_index=True)

# confirm good data
# trips.head()

# remove trips where the bike was not returned properly
trips = trips.dropna()

# put stations into buckets


def get_hour_from_time(x):
    # start and end time helper method
    hour = int(x.split()[1].split(':')[0])
    if hour == 12:
        if x.split()[2] == 'AM':
            hour -= 12
    elif x.split()[2] == 'PM':
        hour += 12
    return hour

# start and end times sorted by frequency
trips['start time'].apply(get_hour_from_time).value_counts()
trips['end time'].apply(get_hour_from_time).value_counts()


# Most common starting stations
# trips['start station'].value_counts()


# Most common ending stations
# trips['end station'].value_counts()


# Most used stations
stations = [trips['start station'], trips['end station']]
my_stations = pd.concat(stations, ignore_index=True)
# my_stations.describe()
# my_stations.value_counts()
my_unique_stations = my_stations.drop_duplicates()

# Descriptive and summary statistics on duration


# def convert_duration_to_secs(x):
#     # duration helper method
#     times = re.findall(r'\d+', x)
#     return int(times[0]) * 60 + int(times[1])
#
# trips['duration'].apply(convert_duration_to_secs).describe()


# What stations have I not been to?
url = "https://www.citibikenyc.com/stations/json"
all_stations = pd.read_json(url)['stationBeanList']
all_stations = all_stations.apply(lambda x: x['stationName'])

# decode html
html_parser = HTMLParser.HTMLParser()
my_unique_stations_decoded = my_unique_stations.apply(html_parser.unescape)

# exclude visited stations
not_visited_station = lambda x: x not in my_unique_stations_decoded.values
not_visited_stations = all_stations.apply(not_visited_station)
