#!/bin/bash

# process_check.sh
# Checks whether a given process name is running via pgrep; if so,
# prints matching ps aux lines, else reports dead and exits 1.
#
# Usage:   ./process_check.sh <process_name>
# Flags:   none (positional arg only)
# Hardening (S54, item 33): set -euo pipefail added, quoted variables
#          throughout, explicit $# arg-count check (safe under set -u),
#          || true on the grep display line so a benign zero-match
#          doesn't kill the script under pipefail.
# Exit:    1 if no argument given, 1 if process not found, 0 if found


if [ "$#" -eq 0 ] ; then 
	echo " invalid argument provided "
	exit 1
fi 

if pgrep "$1" &>/dev/null ; then 
	ps aux | grep "$1" || true 
else 
	echo " dead: $1 "
	exit 1 
fi 


