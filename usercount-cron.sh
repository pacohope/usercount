#!/bin/bash
#
# Cron script for running diasporacount.py
#
# Run it hourly (but not exactly on the 0th minute of the hour)
#
# 4 * * * * /home/diaspora/usercount/usercount-cron.sh
#

PYTHON="/usr/bin/python3"
DIASPORA="/home/diaspora"
COUNTHOME="${DIASPORA}/usercount"
CSV="${COUNTHOME}/diasporastats.csv"
YAML="${DIASPORA}/diaspora/config/database.yml"
ASSETS="${DIASPORA}/diaspora/public/assets/"
LOGFILE="${COUNTHOME}/cron.log"
# do you use S3? Define a bucket name here
BUCKET="assets.grumpy.world"

cd "${COUNTHOME}"
# if there ever isn't a CSV file, we should create one.
if [ ! -f "${CSV}" ]
then
    echo "timestamp,usercount,postscount" > "${CSV}"
fi

# delete the old cron log file so we don't just grow and grow.
[ -f "${LOGFILE}" ] && rm -f "${LOGFILE}"

# Run the command
${PYTHON} "${COUNTHOME}/diasporacount.py" \
  --database "${YAML}" \
  --csv "${CSV}" > "${LOGFILE}" 2>&1

# If we produced a graph bigger than size 0, copy it into place
if [ -s "graph.png" ]
then
    cp graph.png "${DIASPORA}/diaspora/public/assets/"
    if [ "${BUCKET}" != "" ]
    then
        aws s3 cp graph.png s3://${BUCKET}/ --cache-control 3600s --acl public-read
    fi
fi