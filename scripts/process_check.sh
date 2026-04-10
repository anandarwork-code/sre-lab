#!/bin/bash

if pgrep $1 &>/dev/null ; then 
	ps aux | grep $1
else
	echo "dead:$1" 
	exit 1
fi

