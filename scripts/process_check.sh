#!/bin/bash
# process_check.sh
# Checks whether a given process name is running via pgrep; if so,
# prints matching ps aux lines, else reports dead and exits 1.
#
# Usage:   ./process_check.sh <process_name>
# Flags:   none (positional arg only)
# Known limitation: no arg-check — calling with no argument passes an
#          empty pattern to pgrep rather than erroring cleanly
# Exit:    1 if process not found, 0 if found

if pgrep $1 &>/dev/null ; then 
	ps aux | grep $1
else
	echo "dead:$1" 
	exit 1
fi

