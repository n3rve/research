#!/bin/bash

# Script to automatically sync local directories with AWS S3.
# Backups will be stored at `/srv/S3`.

# S3 - This is the name of your Amazon S3 bucket. Replace "n3rve/dump" with your bucket name & the folder where you want the file(s) and database stored.
# SITE - This will be included in the compressed file(s) created to help ID them.
# SOURCE - This script will compress the target directory.
# DB - The database to backup.
# DB_USER - The database user && DB_PW - The database password. 

S3="s3://acms-2015/rusangu"
SITE="rusangu"
SOURCE="srv/acms_app"
DB="acms"
DB_USER="root"
DB_PW="O2O0t7gK"

##### YOU DO NOT HAVE TO EDIT BELOW THIS LINE #####

DATE=`date +%d%m%y%H%M`
echo "Creating Directories";
mkdir -p /srv/S3/$DATE;

sleep 2
echo "Starting Database Backup";
mysqldump -u $DB_USER -p${DB_PW} $DB | gzip > /srv/S3/$DATE/db_${SITE}_${DB}_${DATE}.gz

sleep 3
echo "Compressing Site Code"
tar czf /srv/S3/$DATE/code_${SITE}_${DATE}.tar.gz -C / ${SOURCE}

sleep 5
echo "Beginning Sync"
# /usr/local/bin/aws s3 sync /srv/S3/ ${S3}

find /srv/S3 -mindepth 1 -maxdepth 1 -type d -mtime +30 | xargs rm -rf
/usr/local/bin/aws s3 sync --delete /srv/S3/ ${S3} >> /opt/sync.log

GR='\033[1;32m'; NC='\033[0m';
printf "${GR}Sync to ${S3} complete.${NC}\n"

#Find all the site* or db* prefixed files in /var/www/_backups that were last modified more than 5 days ago and remove them.
# find /var/www/_backups/site* -mtime +5 -exec rm {} \;
