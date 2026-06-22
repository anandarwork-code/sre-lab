#!/bin/bash
# Problem:  MySQL databases (srelab, gitea) require manual intervention for backups,
#           creating risk of data loss in the event of corruption or failure.
# Approach: Automated script dumps both databases to timestamped .sql files in
#           /var/backups/mysql, logs each operation, and deletes backups older
#           than 7 days to manage disk usage.
# Usage:    Run manually or via cron (daily 2am). On DB corruption or data loss,
#           restore with: mysql -u root <db_name> < <backup_file>.sql


user=root
#ip=localhost
backup_dir=/var/backups/mysql
log_file=/var/log/mysql_backup.log
date=$(date +"%Y-%m-%d_%H-%M-%S")

db_1=srelab
db_2=gitea
echo "---------------------------------------------------------------"
mysqldump -u root "$db_1" > "$backup_dir"/"$date"_"$db_1"_backup.sql
echo " $date mysqldump  $db_1 backup done" >>$log_file
echo "---------------------------------------------------------------"
mysqldump -u root  "$db_2">  "$backup_dir"/"$date"_"$db_2"_backup.sql
echo " $date mysqldump  $db_2 backup done" >>$log_file
echo "---------------------------------------------------------------"
find /var/backups/mysql -mtime +7 -type f -delete
echo " $date removed old log files " >>$log_file
