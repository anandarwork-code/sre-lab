#!/bin/bash

# check_mysql.sh
# Checks whether the mysqld service is active on this host and logs the
# result with a timestamp.
#
# Usage:   ./check_mysql.sh
# Flags:   none
# Output:  appended to /var/log/mysql_log.txt
# Exit:    0 always (does not currently propagate mysqld's actual state
#          as an exit code — caller must grep the log/output)

for p in mysqld; do

	if systemctl is-active $p --quiet; then 
		echo "$p is active and running $(date) " | tee -a /var/log/mysql_log.txt

  else 
	  echo " $p is not running : $(date)" |  tee -a /var/log/mysql_log.txt
  
	fi 
done
