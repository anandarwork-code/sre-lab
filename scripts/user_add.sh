#!/bin/bash

if [ -z "$1" ] ; then 
	echo " usage: $0 <username>"
	exit 1
fi 

user=$1

if id "$user" &>/dev/null; then 
	echo "error : user $user already exist"
        exit 1
fi

sudo useradd -m -s /bin/bash $user
sudo mkdir -p /home/$user/.ssh
sudo touch /home/$user/.ssh/authorized_keys
sudo chown -R $user:$user /home/$user/.ssh
sudo chmod 700 /home/$user/.ssh
sudo chmod 600 /home/$user/.ssh/authorized_keys

echo " $user ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx" | sudo tee -a /etc/sudoers.d/$user
sudo chmod 440 /etc/sudoers.d/$user

echo "User $user created - add SSH key to /home/$user/.ssh/authorized_keys "
