#!/bin/bash

for p in mysqld; do

	if systemctl is-active $p --quiet; then 
		echo "$p is active and running $(date) " | tee -a /var/log/mysql_log.txt

  else 
	  echo " $p is not running : $(date)" |  tee -a /var/log/mysql_log.txt
  
	fi 
done
