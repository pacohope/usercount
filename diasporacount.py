#!/usr/local/bin/python3
import psycopg2
import argparse
import time
import csv
from subprocess import call
from yaml import load, load_all

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader

# Returns the timestamp,usercount pair which is closest to the specified timestamp
def find_closest_timestamp( input_dict, seek_timestamp ):
    a = []
    for item in input_dict:
        a.append( item['timestamp'] )
    return input_dict[ min(range(len(a)), key=lambda i: abs(a[i]-seek_timestamp)) ]

# Get the current count of non-deleted users from the database
def getCount( dbFile ):

    usercountQuery = 'select count(id) from users where email not like \'deleted_%\';'
    # adapted from presenters/node_info_presenter.rb
    localpostQuery = """select count(posts.guid) from posts join people on posts.author_id = 
         people.id where posts.type = \'StatusMessage\' AND people.owner_id IS NOT null;"""
    
    conn = None
    dbData = load(dbFile, Loader=Loader)
    params = {}
    
    params['host']     = dbData['postgresql']['host']
    params['dbname']   = dbData['production']['database']
    params['user']     = dbData['postgresql']['username']
    params['port']     = dbData['postgresql']['port']
    params['password'] = dbData['postgresql']['password']

    conn = psycopg2.connect(**params)
 
    # create a cursor
    cur = conn.cursor()
    
    try:
        # get non-deleted users
        cur.execute(usercountQuery)
        usercount = cur.fetchone()[0]
        # print( "User count: {}".format(usercount) )
        cur.execute(localpostQuery)
        localposts = cur.fetchone()[0]
        # print( "Post count: {}".format(localposts) )
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
    return(usercount, localposts)
 
 
if __name__ == '__main__':
        # Handle command line
    parser = argparse.ArgumentParser(
        description="Generate daily diaspora user stats off postgres."
    )
    parser.add_argument('-c', '--csv', type=argparse.FileType('a'),
         default='./diasporastats.csv', required=False,
         help='Name of the CSV file. "./diasporastats.csv" by default')
    parser.add_argument('-d', '--database', type=argparse.FileType('r'),
        default='./secrets/database.yml', required=False,
        help='Database YAML configuration file from diaspora. Default: "./secrets/database.yml"')

    args = parser.parse_args()
    currentCount, numPosts = getCount( args.database )
    # Get current timestamp
    ts = int(time.time())
    # Append to CSV file
    args.csv.write(str(ts) + "," + str(currentCount) + "," + str(numPosts) + "\n")

    # rewind to the beginning of the file
    args.csv = open(args.csv.name)
    # Load CSV file
    with args.csv as f:
        usercount_dict = [{k: int(v) for k, v in row.items()}
            for row in csv.DictReader(f, skipinitialspace=True)]

    # Calculate difference in times
    hourly_change_string = ""
    daily_change_string  = ""
    weekly_change_string = ""

    one_hour = 60 * 60
    one_day  = one_hour * 24
    one_week = one_hour * 168

    # Hourly change
    if len(usercount_dict) > 2:
        one_hour_ago_ts = ts - one_hour
        one_hour_ago_val = find_closest_timestamp( usercount_dict, one_hour_ago_ts )
        hourly_change = currentCount - one_hour_ago_val['usercount']
        print ("Hourly change %s"%hourly_change)
        if hourly_change > 0:
            hourly_change_string = "+" + format(hourly_change, ",d") + " in the last hour\n"

    # Daily change
    if len(usercount_dict) > 24:
        one_day_ago_ts = ts - one_day
        one_day_ago_val = find_closest_timestamp( usercount_dict, one_day_ago_ts )
        daily_change = currentCount - one_day_ago_val['usercount']
        print ("Daily change %s"%daily_change)
        if daily_change > 0:
            daily_change_string = "+" + format(daily_change, ",d") + " in the last day\n"

    # Weekly change
    if len(usercount_dict) > 168:
        one_week_ago_ts = ts - one_week
        one_week_ago_val = find_closest_timestamp( usercount_dict, one_week_ago_ts )
        weekly_change = currentCount - one_week_ago_val['usercount']
        print ("Weekly change %s"%weekly_change)
        if weekly_change > 0:
            weekly_change_string = "+" + format(weekly_change, ",d") + " in the last week\n"

    # Generate chart
    call(["gnuplot", "generate.gnuplot"])