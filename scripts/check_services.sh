#!/bin/bash 
# check_services.sh
# Checks whether sshd, httpd, and libvirtd are active and prints a
# running/total summary.
#
# Usage:   bash check_services.sh   (not yet chmod +x)
# Flags:   none
# Output:  stdout only, no log file
# Exit:    0 always — does not fail even if services are down

echo "====================== services  check=============================="

total=0
running=0

for p in sshd httpd libvirtd ; do 
	((total++))
	if systemctl is-active "$p" --quiet ; then 
		((running++))
	  echo "Ok $p is running "
        else 
	  echo " FAIL $p is not running"

	fi 
done
	echo "number of services running : $running/$total "
