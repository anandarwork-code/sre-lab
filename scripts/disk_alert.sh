
#!/bin/bash
# disk_alert.sh
# Checks disk usage per mount via df, logs a warning line for any
# filesystem at or above threshold. Intended for cron.
#
# Usage:   ./disk_alert.sh
# Flags:   none (threshold hardcoded to 80%)
# Output:  appended to /var/log/disk_alert.log (only on breach)
# Exit:    0 always — does not signal breach via exit code
# Cron:    runs every 15 min

threshold=80

threshold=80
log_file=/var/log/disk_alert.log
timestamp=$(date +"%Y_%m_%d-%H_%M_%S")

df --output=source,pcent | tail -n +2 | while read source pcent; do 
usage=${pcent%\%}
if [ "$usage" -ge "$threshold" ]; then
	echo "$timestamp: $source storage is full!! " | sudo tee -a $log_file
fi
done
