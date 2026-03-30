#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'   # NC = No Color — resets back to normal

sre_vm1=192.168.122.152
sre_db=192.168.122.127
sre_mon=192.168.122.218
SSH_USER=anand

echo "[sre-vm1] nginx:"
result_vm1=$(ssh $SSH_USER@$sre_vm1 "systemctl is-active nginx")
if [ "$result_vm1" == "active" ]; then 
	echo -e "${GREEN}OK${NC}"
else 
        echo -e "${RED}FAIL${NC}"
fi

echo "[sre-db] mysql:"
result_db=$(ssh $SSH_USER@$sre_db "systemctl is-active mysqld")
if [ "$result_db" == "active" ]; then
	echo -e "${GREEN}OK${NC}"
else 
	echo -e "${RED}FAIL${NC}"
fi

echo "[sre-mon] prometheus:"
result_mon=$(ssh $SSH_USER@$sre_mon "systemctl is-active prometheus")
if [ "$result_mon" == "active" ]; then 
	echo -e "${GREEN}OK${NC}"
else 
	echo -e "${RED}FAIL${NC}"
fi
