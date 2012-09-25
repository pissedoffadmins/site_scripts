#!/bin/bash

######
# this script uses s3cmd from http://s3tools.org/s3cmd to sync a folder in linux to s3
#
# make sure that you have configured s3cmd by running s3cmd --configure
#
# this script is usally kept in a cron to be run every x amount of hours
######

S3CMD=`which s3cmd`
S3CMD_OPTIONS="--recursive put"
BKUP_PATH=CHANGE THIS TO PATH WHERE FOLDERS ARE LOCATED
BUCKET=s3://CHANGE THIS TO S3 BUCKET NAME FROM "s3cmd ls"/
LIST=/tmp/S3CMD.$$
DIR=/tmp/DIR.$$
touch $LIST $DIR

#### you should not have to change anything below this line ####

# check if s3cmd exists
if [[ -z ${S3CMD} ]]; then
    printf "\ns3cmd not found.\nInstall s3cmd from http://s3tools.org/s3cmd\n"
    exit 1
fi

# use s3cmd to print a list of existing folders in bucket
${S3CMD} la > $LIST

# check if folders in $BKUP_PATH exist in s3, if not then copy them there
for DIR_CHECK in `ls -al $BKUP_PATH | awk '{print $9}' | tail -n +4 | tr '/' ' ' ` ; do
    if [[ $(grep -c $DIR_CHECK $LIST) -gt 0 ]]; then
        printf "\n${DIR_CHECK} exists in s3."
    else
        printf "\n${DIR_CHECK} does not exist at s3."
        printf "\nadding now:\n"
        ${S3CMD} ${S3CMD_OPTIONS} ${BKUP_PATH}/${DIR_CHECK} ${BUCKET}
    fi
done

# delete temporary files
rm -rf $LIST
rm -rf $DIR
