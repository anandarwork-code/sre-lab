#!/bin/bash
# user_add.sh
# Creates a new user with a home dir, sets up an empty .ssh/authorized_keys
# with correct permissions, and grants passwordless sudo for a single
# specific command (systemctl restart nginx) via a dedicated sudoers.d file.
#
# Usage:   ./user_add.sh <username>
# Flags:   none (positional arg only)
# Exits early (code 1) if: no username given, or user already exists
# Note:    the nginx-restart sudo grant is unconditional for every user
#          this script creates — not opt-in. Intentional for this lab's
#          use case (ops users need to bounce nginx) but worth knowing
#          before reusing this script in a different context.

if [ -z "$1" ] ; then


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
