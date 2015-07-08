#!/bin/bash

# Script to automatically sync local directories with AWS S3.
# Backups will be stored at `/srv/S3`.

# S3 - This is the name of your Amazon S3 bucket. Replace "n3rve/dump" with your bucket name & the folder where you want the file(s) and database stored.
# SITE - This will be included in the compressed file(s) created to help ID them.
# SOURCE - This script will compress the target directory.
# DB - The database to backup.
# DB_USER - The database user && DB_PW - The database password. 

S3="s3://n3rve/dump"
SITE="ralph.com.ng"
SOURCE="srv/app"
DB="mydb"
DB_USER="root"
DB_PW="x83rh93rh"

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
/usr/local/bin/aws s3 sync /srv/S3/ ${S3}

GR='\033[1;32m'; NC='\033[0m';
printf "${GR}Sync to ${S3} complete.${NC}\n"
